describe Proposal do
  describe "Associatons" do
    it { should belong_to(:client_data).dependent(:destroy) }
    it { should have_many(:steps) }
    it { should have_many(:individual_steps) }
    it { should have_many(:attachments).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:approval_steps) }
    it { should have_many(:purchase_steps) }
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

  describe "#root_step" do
    it "returns the step without a parent" do
      step = create(:serial_step, parent_id: nil)
      proposal = create(:proposal, steps: [step])

      expect(proposal.root_step).to eq step
    end
  end

  describe "#parallel?" do
    it "is true if the root step is a parallel step" do
      proposal = create(:proposal, steps: [create(:parallel_step)])

      expect(proposal).to be_parallel
    end

    it "is false if the root step is not a parallel step" do
      proposal = create(:proposal, steps: [create(:serial_step)])

      expect(proposal).not_to be_parallel
    end
  end

  describe "#serial?" do
    it "is true if the root step is a serial step" do
      proposal = create(:proposal, steps: [create(:serial_step)])

      expect(proposal).to be_serial
    end

    it "is false if the root step is not a serial step" do
      proposal = create(:proposal, steps: [create(:parallel_step)])

      expect(proposal).not_to be_serial
    end
  end

  describe "#delegate?" do
    context "user is a delegate for one of the step users" do
      it "is true" do
        user = create(:user)
        proposal = create(:proposal, delegate: user)

        expect(proposal.delegate?(user)).to eq true
      end
    end

    context "user is not delegate for one of the step users" do
      it "is false" do
        user = create(:user)
        proposal = create(:proposal)

        expect(proposal.delegate?(user)).to eq false
      end
    end
  end

  describe '#currently_awaiting_step_users' do
    it "gives a consistently ordered list when in parallel" do
      proposal = create(:proposal, :with_parallel_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_step_users).to eq([approver1, approver2])

      proposal.individual_steps.first.update_attribute(:position, 5)
      expect(proposal.currently_awaiting_step_users).to eq([approver2, approver1])
    end

    it "gives only the first approver when linear" do
      proposal = create(:proposal, :with_serial_approvers)
      approver1, approver2 = proposal.approvers
      expect(proposal.currently_awaiting_step_users).to eq([approver1])

      proposal.individual_steps.first.complete!
      expect(proposal.currently_awaiting_step_users).to eq([approver2])
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
    it "returns all approvers, purchasers, observers, and the requester" do
      requester = create(:user)
      proposal = create(:proposal, :with_approval_and_purchase, :with_observers, requester: requester)

      expect(proposal.subscribers.map(&:id).sort).to eq([
        requester.id,
        proposal.approvers.first.id,
        proposal.purchasers.first.id,
        proposal.observers.first.id,
        proposal.observers.second.id
      ].sort)
    end

    it "returns only the requester when it has no other users" do
      proposal = create(:proposal)
      expect(proposal.subscribers).to eq([proposal.requester])
    end

    it "includes observers" do
      observer = create(:user)
      proposal = create(:proposal, requester: observer)
      proposal.add_observer(observer)
      expect(proposal.subscribers).to eq [observer]
    end

    it "removes duplicates" do
      requester = create(:user)
      proposal = create(:proposal, requester: requester)
      proposal.add_observer(requester)
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
    it 'sets initial approvers' do
      proposal = create(:proposal)
      approvers = 3.times.map{ create(:user) }
      individuals = approvers.map{ |u| Steps::Approval.new(user: u) }

      proposal.root_step = Steps::Parallel.new(child_steps: individuals)

      expect(proposal.steps.count).to be 4
      expect(proposal.approvers).to eq approvers
    end

    it 'initates parallel' do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal)
      individuals = [approver1, approver2, approver3].map{ |u| Steps::Approval.new(user: u)}

      proposal.root_step = Steps::Parallel.new(child_steps: individuals)

      expect(proposal.approvers.count).to be 3
      expect(proposal.steps.count).to be 4
      expect(proposal.individual_steps.actionable.count).to be 3
      expect(proposal.steps.actionable.count).to be 4
    end

    it 'initates linear' do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal)
      individuals = [approver1, approver2, approver3].map{ |u| Steps::Approval.new(user: u)}

      proposal.root_step = Steps::Serial.new(child_steps: individuals)

      expect(proposal.approvers.count).to be 3
      expect(proposal.steps.count).to be 4
      expect(proposal.individual_steps.actionable.count).to be 1
      expect(proposal.steps.actionable.count).to be 2
    end

    it "fixes modified parallel proposal approvals" do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal)
      individuals = [Steps::Approval.new(user: approver1)]
      proposal.root_step = Steps::Parallel.new(child_steps: individuals)

      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_steps.actionable.count).to be 1

      individuals = individuals + [approver2, approver3].map{ |u| Steps::Approval.new(user: u)}
      proposal.root_step = Steps::Parallel.new(child_steps: individuals)

      expect(proposal.steps.actionable.count).to be 4
      expect(proposal.individual_steps.actionable.count).to be 3
    end

    it "fixes modified proposal approvals with serial steps" do
      approver1 = create(:user)
      approver2 = create(:user)
      approver3 = create(:user)
      proposal = create(:proposal)
      approver1, approver2, approver3 = 3.times.map{ create(:user) }
      individuals = [approver1, approver2].map{ |u| Steps::Approval.new(user: u) }
      proposal.root_step = Steps::Serial.new(child_steps: individuals)

      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_steps.actionable.count).to be 1

      individuals.first.complete!
      individuals[1] = Steps::Approval.new(user: approver3)
      proposal.root_step = Steps::Serial.new(child_steps: individuals)

      expect(proposal.steps.completed.count).to be 1
      expect(proposal.steps.actionable.count).to be 2
      expect(proposal.individual_steps.actionable.count).to be 1
      expect(proposal.individual_steps.actionable.first.user).to eq approver3
    end

    it "does not modify a fully completed proposal with parallel steps" do
      approver1 = create(:user)
      approver2 = create(:user)
      proposal = create(:proposal)
      individuals = [approver1, approver2].map{ |u| Steps::Approval.new(user: u)}
      proposal.root_step = Steps::Parallel.new(child_steps: individuals)

      proposal.individual_steps.first.complete!
      proposal.individual_steps.second.complete!

      expect(proposal.steps.actionable).to be_empty
    end

    it "does not modify a fully completed proposal with serial steps" do
      approver1 = create(:user)
      approver2 = create(:user)
      proposal = create(:proposal)
      individuals = [approver1, approver2].map{ |u| Steps::Approval.new(user: u)}
      proposal.root_step = Steps::Serial.new(child_steps: individuals)

      proposal.individual_steps.first.complete!
      proposal.individual_steps.second.complete!

      expect(proposal.steps.actionable).to be_empty
    end

    it "deletes approvals" do
      proposal = create(:proposal, :with_parallel_approvers)
      approval1, approval2 = proposal.individual_steps
      proposal.root_step = Steps::Serial.new(child_steps: [approval2])

      expect(Step.exists?(approval1.id)).to be false
    end
  end

  describe '#reset_status' do
    it 'sets status as completed if there are no approvals' do
      proposal = create(:proposal)
      expect(proposal.pending?).to be true
      proposal.reset_status()
      expect(proposal.completed?).to be true
    end

    it "keeps status as canceled if the proposal has been canceled" do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_steps.first.complete!
      expect(proposal.pending?).to be true
      proposal.cancel!

      proposal.reset_status()
      expect(proposal.canceled?).to be true
    end

    it 'reverts to pending if a step is added' do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.individual_steps.first.complete!
      proposal.individual_steps.second.complete!
      expect(proposal.reload.completed?).to be true
      individuals = proposal.root_step.child_steps + [Steps::Approval.new(user: create(:user))]
      proposal.root_step = Steps::Parallel.new(child_steps: individuals)

      proposal.reset_status()
      expect(proposal.pending?).to be true
    end

    it 'does not move out of the pending state unless all are completed' do
      proposal = create(:proposal, :with_parallel_approvers)
      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.individual_steps.first.complete!

      proposal.reset_status()
      expect(proposal.pending?).to be true
      proposal.individual_steps.second.complete!

      proposal.reset_status()
      expect(proposal.completed?).to be true
    end
  end

  describe "scopes" do
    let(:statuses) { %w(pending completed canceled) }
    let!(:proposals) { statuses.map { |status| create(:proposal, status: status) } }

    it "returns the appropriate proposals by status" do
      statuses.each do |status|
        expect(Proposal.send(status).pluck(:status)).to eq([status])
      end
    end

    describe '.closed' do
      it "returns completed and and canceled proposals" do
        expect(Proposal.closed.pluck(:status).sort).to eq(%w(canceled completed))
      end
    end
  end

  describe '#restart' do
    it "creates new API tokens" do
      proposal = create(:proposal, :with_parallel_approvers)
      create(:ncr_work_order, proposal: proposal)

      proposal.individual_steps.each do |step|
        create(:api_token, step: step)
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

  describe "#tags" do
    it "can add case-insensitive tags" do
      proposal = create(:proposal)
      proposal.tag_list = "foo, bar, BAZ"
      proposal.save!
      expect(proposal.tag_list).to eq(["foo", "bar", "baz"])
    end
  end

  describe "#as_indexed_json" do
    it "counts attachments" do
      proposal = create(:proposal)
      attachment = create(:attachment, proposal: proposal, user: proposal.requester)

      expect(proposal.as_indexed_json[:num_attachments]).to eq(1)
    end

    it "uses requester.display_name as requester" do
      proposal = create(:proposal)

      expect(proposal.as_indexed_json[:requester]).to eq(proposal.requester.display_name)
    end
  end

  describe "#fully_complete!" do
    it "handles all steps and status" do
      proposal = create(:proposal, :with_serial_approvers)

      proposal.fully_complete!

      expect(proposal.status).to eq 'completed'
    end
  end
end
