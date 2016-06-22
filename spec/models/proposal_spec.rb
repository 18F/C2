describe Proposal do
  describe "Associatons" do
    it { should belong_to(:client_data).dependent(:destroy) }
    it { should have_many(:steps) }
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

  describe "CLIENT_MODELS" do
    it "contains multiple models" do
      expect(Proposal::CLIENT_MODELS.size).to_not eq(0)
      Proposal::CLIENT_MODELS.each do |model|
        expect(model.ancestors).to include(ActiveRecord::Base)
      end
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

  describe "#subscribers" do
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

  describe "subscribers_except_future_step_users" do
    let (:proposal) { create(:proposal, :with_serial_approvers, :with_observers) }

    it "includes the requester" do
      expect(proposal.subscribers_except_future_step_users).to include(proposal.requester)
    end

    it "includes an observer" do
      expect(proposal.subscribers_except_future_step_users).to include(proposal.observers.first)
    end

    it "includes approved approvers" do
      individuals = proposal.individual_steps
      individuals += [Steps::Approval.new(user: create(:user))]
      proposal.root_step = Steps::Serial.new(child_steps: individuals)
      expect(proposal.approvers.length).to eq(3)
      proposal.individual_steps.first.complete!
      expect(proposal.subscribers_except_future_step_users).to include(proposal.approvers[0])
      expect(proposal.subscribers_except_future_step_users).to include(proposal.approvers[1])
      expect(proposal.subscribers_except_future_step_users).not_to include(proposal.approvers[2])
    end
  end

  describe "#eligible_observers" do
    it "identifies eligible observers" do
      observer = create(:user, client_slug: nil)
      proposal = create(:proposal, requester: observer)
      expect(proposal.eligible_observers.to_a).to include(observer)
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

  describe "scopes" do
    let(:statuses) { %w(pending completed canceled) }
    let!(:proposals) { statuses.map { |status| create(:proposal, status: status) } }

    # TODO: Fix this brittle spec

    # it "returns the appropriate proposals by status" do
    #   statuses.each do |status|
    #     expect(Proposal.send(status).pluck(:status)).to eq([status])
    #   end
    # end

    describe ".closed" do
      it "returns completed and and canceled proposals" do
        expect(Proposal.closed.pluck(:status).sort).to eq(%w(canceled completed))
      end
    end
  end

  describe "#restart" do
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
      create(:attachment, proposal: proposal, user: proposal.requester)

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

      expect(proposal.status).to eq "completed"
    end

    it "does not send notifications if explicitly prevented" do
      proposal = create(:proposal, :with_serial_approvers)
      deliveries.clear
      proposal.fully_complete!(nil, true)

      expect(proposal.status).to eq "completed"
      expect(deliveries.count).to eq 0
    end
  end

  describe "searchable callbacks" do
    it "should reindex when observer is added without comment" do
      Proposal.clear_index_tracking
      proposal = create(:proposal)
      create(:observation, proposal: proposal)

      expect(Proposal.reindexed.count).to eq(2)
    end
  end
end
