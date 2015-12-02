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

    it "disallows requester from also being approver" do
      user = create(:user)
      expect {
        create(:proposal, :with_approver, requester: user, approver_user: user) 
      }.to raise_error(ActiveRecord::RecordNotSaved)
    end

    it "disallows assigning requester as approver" do
      proposal = create(:proposal)
      expect {
        proposal.add_initial_steps([Steps::Approval.new(user: proposal.requester)])
      }.to raise_error(ActiveRecord::RecordNotSaved)
    end

    it "disallows assigning approver as requester" do
      proposal = create(:proposal, :with_approver)
      expect {
        proposal.add_requester(proposal.individual_steps.first.user.email_address)
      }.to raise_error(/cannot also be Requester/)
    end
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
    it "gives only the first approver" do
      proposal = create(:proposal, :with_serial_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_approvers).to eq([approver1])

      proposal.individual_steps.first.approve!
      expect(proposal.currently_awaiting_approvers).to eq([approver2])
    end
  end

  describe "#name" do
    it "delegates to client data" do
      proposal = build(:proposal)

      expect(proposal.name).to be_nil
    end
  end

  describe "#fields_for_display" do
    it "returns an empty array by deafult" do
      proposal = build(:proposal)

      expect(proposal.fields_for_display).to eq []
    end
  end

  describe '#subscribers' do
    it "returns all approvers, observers, and the requester" do
      requester = create(:user)
      proposal = create(:proposal, :with_serial_approvers, :with_observers, requester: requester)

      expect(proposal.subscribers.map(&:id).sort).to eq([
        requester.id,
        proposal.approvers.first.id, proposal.approvers.second.id,
        proposal.observers.first.id, proposal.observers.second.id
      ].sort)
    end

    it "returns only the requester when it has no other users" do
      proposal = create(:proposal)
      expect(proposal.subscribers).to eq([proposal.requester])
    end

    it "includes observers" do
      observer = create(:user)
      proposal = create(:proposal, requester: observer)
      proposal.add_observer(observer.email_address)
      expect(proposal.subscribers).to eq [observer]
    end

    it "removes duplicates" do
      requester = create(:user)
      proposal = create(:proposal, requester: requester)
      proposal.add_observer(requester.email_address)
      expect(proposal.subscribers).to eq [requester]
    end
  end

  describe "#eligible_observers" do
    it "identifies eligible observers" do
      observer = create(:user, client_slug: nil)
      proposal = create(:proposal, requester: observer)
      expect(proposal.eligible_observers.to_a).to include(observer)
    end
  end

  describe "#ineligible_approvers" do
    it "identifies ineligible approvers" do
      proposal = create(:proposal)
      expect(proposal.ineligible_approvers).to eq([proposal.requester])
    end
  end

  describe "#subscribers_except_delegates" do
    it "excludes delegates" do
      delegate = create(:user)
      proposal = create(:proposal, :with_approver)
      proposal.approvers.first.add_delegate(delegate)
      expect(proposal.subscribers_except_delegates).to match_array(
        proposal.subscribers - [delegate]
      )
    end
  end

  describe '#root_step=' do
    it 'initates linear' do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal, flow: 'linear')
      individuals = [approver1, approver2, approver3].map{ |u| Steps::Approval.new(user: u)}

      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      expect(proposal.approvers.count).to be 3
      expect(proposal.steps.count).to be 4
      expect(proposal.individual_steps.actionable.count).to be 1
      expect(proposal.steps.actionable.count).to be 2
    end

    it 'fixes modified linear proposal approvals' do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal, flow: 'linear')
      approver1, approver2, approver3 = 3.times.map{ create(:user) }
      individuals = [approver1, approver2].map{ |u| Steps::Approval.new(user: u) }
      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_steps.actionable.count).to be 1

      individuals.first.approve!
      individuals[1] = Steps::Approval.new(user: approver3)
      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      expect(proposal.steps.approved.count).to be 1
      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_steps.actionable.count).to be 1
      expect(proposal.individual_steps.actionable.first.user).to eq approver3
    end

    it 'does not modify a full approved linear proposal' do
      approver1 = create(:user)
      approver2 = create(:user)
      proposal = create(:proposal, flow: 'linear')
      individuals = [approver1, approver2].map{ |u| Steps::Approval.new(user: u)}
      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      proposal.individual_steps.first.approve!
      proposal.individual_steps.second.approve!

      expect(proposal.steps.actionable).to be_empty
    end

    it 'deletes approvals' do
      proposal = create(:proposal, :with_serial_approvers)
      approval1, approval2 = proposal.individual_steps
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

    it "keeps status as cancelled if the proposal has been cancelled" do
      proposal = create(:proposal, :with_approver)
      proposal.individual_steps.first.approve!
      expect(proposal.pending?).to be true
      proposal.cancel!

      proposal.reset_status()
      expect(proposal.cancelled?).to be true
    end

    it 'reverts to pending if an approval is added' do
      proposal = create(:proposal, :with_serial_approvers)
      proposal.individual_steps.first.approve!
      proposal.individual_steps.second.approve!
      expect(proposal.reload.approved?).to be true
      individuals = proposal.root_step.child_approvals + [Steps::Approval.new(user: create(:user))]
      proposal.root_step = Steps::Serial.new(child_approvals: individuals)

      proposal.reset_status()
      expect(proposal.pending?).to be true
    end

    it 'does not move out of the pending state unless all are approved' do
      proposal = create(:proposal, :with_serial_approvers)
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

  describe "#restart" do
    it "creates new API tokens" do
      proposal = create(:proposal, :with_serial_approvers)
      proposal.individual_steps.first.approve!
      proposal.individual_steps.each do |step|
        create(:api_token, step: step)
      end

      expect(proposal.api_tokens.size).to eq(3)

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

      proposal.add_observer(observer.email_address)

      expect(observation_creator_double).to have_received(:run)
    end
  end

  describe "#tags" do
    it "can add case-insensitive tags" do
      proposal = create(:proposal)
      proposal.tag_list = "foo, bar, BAZ"
      proposal.save!
      expect(proposal.tag_list).to eq(["foo", "bar", "baz"])
    end
  end
end
