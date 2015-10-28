describe Proposal do
  describe "Associatons" do
    it { should belong_to(:client_data).dependent(:destroy) }
    it { should have_many(:steps) }
    it { should have_many(:individual_approvals) }
    it { should have_many(:attachments).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe 'CLIENT_MODELS' do
    it "contains multiple models" do
      expect(Proposal::CLIENT_MODELS.size).to_not eq(0)
      Proposal::CLIENT_MODELS.each do |model|
        expect(model.ancestors).to include(ActiveRecord::Base)
      end
    end
  end

  describe '#currently_awaiting_approvers' do
    it "gives a consistently ordered list when in parallel" do
      proposal = create(:proposal, :with_parallel_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_approvers).to eq([approver1, approver2])

      proposal.individual_approvals.first.update_attribute(:position, 5)
      expect(proposal.currently_awaiting_approvers).to eq([approver2, approver1])
    end

    it "gives only the first approver when linear" do
      proposal = create(:proposal, :with_serial_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_approvers).to eq([approver1])

      proposal.individual_approvals.first.approve!
      expect(proposal.currently_awaiting_approvers).to eq([approver2])
    end
  end

  describe '#delegate_with_default' do
    it "returns the delegated value" do
      proposal = Proposal.new
      client_data = double(some_prop: 'foo')
      expect(proposal).to receive(:client_data).and_return(client_data)

      result = proposal.delegate_with_default(:some_prop)
      expect(result).to eq('foo')
    end

    it "returns the default when the delegated value is #blank?" do
      proposal = Proposal.new
      client_data = double(some_prop: '')
      expect(proposal).to receive(:client_data).and_return(client_data)

      result = proposal.delegate_with_default(:some_prop) { 'foo' }
      expect(result).to eq('foo')
    end

    it "returns the default when there is no method on the delegate" do
      proposal = Proposal.new
      expect(proposal).to receive(:client_data).and_return(double)

      result = proposal.delegate_with_default(:some_prop) { 'foo' }
      expect(result).to eq('foo')
    end
  end

  describe '#name' do
    it "returns the #public_identifier by default" do
      proposal = Proposal.new
      expect(proposal).to receive(:id).and_return(6)

      expect(proposal.name).to eq('Request #6')
    end
  end

  describe '#users' do
    it "returns all approvers, observers, and the requester" do
      requester = create(:user)
      proposal = create(:proposal, :with_parallel_approvers, :with_observers, requester: requester)

      expect(proposal.users.map(&:id).sort).to eq([
        requester.id,
        proposal.approvers.first.id, proposal.approvers.second.id,
        proposal.observers.first.id, proposal.observers.second.id
      ].sort)
    end

    it "returns only the rquester when it has no other users" do
      proposal = create(:proposal)
      expect(proposal.users).to eq([proposal.requester])
    end

    it "removes duplicates" do
      requester = create(:user)
      proposal = create(:proposal, requester: requester)
      proposal.add_observer(requester.email_address)
      expect(proposal.users).to eq [requester]
    end

    it "adds observer from user object" do
      observer = create(:user)
      proposal = create(:proposal, requester: observer)
      proposal.add_observer(observer)
      expect(proposal.users).to eq [observer]
    end
  end

  describe '#root_approval=' do
    it 'sets initial approvers' do
      proposal = create(:proposal)
      approvers = 3.times.map{ create(:user) }
      individuals = approvers.map{ |u| Steps::Individual.new(user: u) }

      proposal.root_step = Steps::Parallel.new(child_approvals: individuals)

      expect(proposal.steps.count).to be 4
      expect(proposal.approvers).to eq approvers
    end

    it 'initates parallel' do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal, flow: 'parallel')
      individuals = [approver1, approver2, approver3].map{ |u| Steps::Individual.new(user: u)}

      proposal.root_step = Steps::Parallel.new(child_approvals: individuals)

      expect(proposal.approvers.count).to be 3
      expect(proposal.steps.count).to be 4
      expect(proposal.individual_approvals.actionable.count).to be 3
      expect(proposal.steps.actionable.count).to be 4
    end

    it 'initates linear' do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal, flow: 'linear')
      individuals = [approver1, approver2, approver3].map{ |u| Steps::Individual.new(user: u)}

      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      expect(proposal.approvers.count).to be 3
      expect(proposal.steps.count).to be 4
      expect(proposal.individual_approvals.actionable.count).to be 1
      expect(proposal.steps.actionable.count).to be 2
    end

    it 'fixes modified parallel proposal approvals' do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal, flow: 'parallel')
      individuals = [Steps::Individual.new(user: approver1)]
      proposal.root_step = Steps::Parallel.new(child_approvals: individuals)

      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_approvals.actionable.count).to be 1

      individuals = individuals + [approver2, approver3].map{ |u| Steps::Individual.new(user: u)}
      proposal.root_step = Steps::Parallel.new(child_approvals: individuals)

      expect(proposal.steps.actionable.count).to be 4
      expect(proposal.individual_approvals.actionable.count).to be 3
    end

    it 'fixes modified linear proposal approvals' do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal, flow: 'linear')
      approver1, approver2, approver3 = 3.times.map{ create(:user) }
      individuals = [approver1, approver2].map{ |u| Steps::Individual.new(user: u) }
      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_approvals.actionable.count).to be 1

      individuals.first.approve!
      individuals[1] = Steps::Individual.new(user: approver3)
      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      expect(proposal.steps.approved.count).to be 1
      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_approvals.actionable.count).to be 1
      expect(proposal.individual_approvals.actionable.first.user).to eq approver3
    end

    it 'does not modify a full approved parallel proposal' do
      approver1 = create(:user)
      approver2 = create(:user)
      proposal = create(:proposal, flow: 'parallel')
      individuals = [approver1, approver2].map{ |u| Steps::Individual.new(user: u)}
      proposal.root_step = Steps::Parallel.new(child_approvals: individuals)

      proposal.individual_approvals.first.approve!
      proposal.individual_approvals.second.approve!

      expect(proposal.steps.actionable).to be_empty
    end

    it 'does not modify a full approved linear proposal' do
      approver1 = create(:user)
      approver2 = create(:user)
      proposal = create(:proposal, flow: 'linear')
      individuals = [approver1, approver2].map{ |u| Steps::Individual.new(user: u)}
      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      proposal.individual_approvals.first.approve!
      proposal.individual_approvals.second.approve!

      expect(proposal.steps.actionable).to be_empty
    end

    it 'deletes approvals' do
      proposal = create(:proposal, :with_parallel_approvers)
      approval1, approval2 = proposal.individual_approvals
      proposal.root_step = Steps::Serial.new(child_approvals: [approval2])

      expect(Step.exists?(approval1.id)).to be false
    end
  end

  describe '#reset_status' do
    it 'sets status as approved if there are no approvals' do
      proposal = create(:proposal)
      expect(proposal.pending?).to be true
      proposal.reset_status()
      expect(proposal.approved?).to be true
    end

    it 'sets status as cancelled if the proposal has been cancelled' do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_approvals.first.approve!
      expect(proposal.pending?).to be true
      proposal.cancel!

      proposal.reset_status()
      expect(proposal.cancelled?).to be true
    end

    it 'reverts to pending if an approval is added' do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_approvals.first.approve!
      proposal.individual_approvals.second.approve!
      expect(proposal.reload.approved?).to be true
      individuals = proposal.root_step.child_approvals + [Steps::Individual.new(user: create(:user))]
      proposal.root_step = Steps::Parallel.new(child_approvals: individuals)

      proposal.reset_status()
      expect(proposal.pending?).to be true
    end

    it 'does not move out of the pending state unless all are approved' do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.individual_approvals.first.approve!

      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.individual_approvals.second.approve!

      proposal.reset_status()
      expect(proposal.approved?).to be true
    end
  end

  describe "scopes" do
    let(:statuses) { %w(pending approved cancelled) }
    let!(:proposals) { statuses.map{|status| create(:proposal, status: status) } }

    it "returns the appropriate proposals by status" do
      statuses.each do |status|
        expect(Proposal.send(status).pluck(:status)).to eq([status])
      end
    end

    describe '.closed' do
      it "returns approved and and cancelled proposals" do
        expect(Proposal.closed.pluck(:status).sort).to eq(%w(approved cancelled))
      end
    end
  end

  describe '#restart' do
    it "creates new API tokens" do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_approvals.each do |approval|
        create(:api_token, step: approval)
      end

      expect(proposal.api_tokens.size).to eq(2)

      proposal.restart!

      expect(proposal.api_tokens.unscoped.expired.size).to eq(2)
      expect(proposal.api_tokens.unexpired.size).to eq(2)
    end
  end

  describe "#add_observer" do
    it "runs the observation creator service class" do
      proposal = create(:proposal)
      observer = create(:user)
      observation_creator_double = double(run: true)
      allow(ObservationCreator).to receive(:new).with(
        observer: observer,
        proposal_id: proposal.id,
        reason: nil,
        observer_adder: nil
      ).and_return(observation_creator_double)

      proposal.add_observer(observer)

      expect(observation_creator_double).to have_received(:run)
    end
  end
end
