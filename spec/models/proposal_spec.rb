describe Proposal do
  describe "Associatons" do
    it { should belong_to(:client_data).dependent(:destroy) }
    it { should have_many(:steps) }
    it { should have_many(:delegates) }
    it { should have_many(:individual_steps) }
    it { should have_many(:attachments).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_uniqueness_of(:public_id).allow_nil }
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

      proposal.individual_steps.first.update_attribute(:position, 5)
      expect(proposal.currently_awaiting_approvers).to eq([approver2, approver1])
    end

    it "gives only the first approver when linear" do
      proposal = create(:proposal, :with_serial_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_approvers).to eq([approver1])

      proposal.individual_steps.first.approve!
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
    it "returns the #public_id by default" do
      proposal = build(:proposal, public_id: "#6")

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

    it "uses 'subscribers' as an aliased method" do
      proposal = create(:proposal)
      expect(proposal.users).to eq(proposal.subscribers)
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

  describe '#reset_status' do
    it 'sets status as approved if there are no approvals' do
      proposal = create(:proposal)
      expect(proposal.pending?).to be true
      proposal.reset_status()
      expect(proposal.approved?).to be true
    end

    it 'sets status as cancelled if the proposal has been cancelled' do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_steps.first.approve!
      expect(proposal.pending?).to be true
      proposal.cancel!

      proposal.reset_status()
      expect(proposal.cancelled?).to be true
    end

    it 'reverts to pending if an approval is added' do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_steps.first.approve!
      proposal.individual_steps.second.approve!
      expect(proposal.reload.approved?).to be true
      individuals = proposal.root_step.child_approvals + [Steps::Approval.new(user: create(:user))]
      proposal.root_step = Steps::Parallel.new(child_approvals: individuals)

      proposal.reset_status()
      expect(proposal.pending?).to be true
    end

    it 'does not move out of the pending state unless all are approved' do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.individual_steps.first.approve!

      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.individual_steps.second.approve!

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
      proposal.individual_steps.each do |approval|
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
