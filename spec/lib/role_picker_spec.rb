describe RolePicker do
  describe  "#new" do
    describe "#requester?" do
      it "is the true when user is proposal requester" do
        proposal = create(:proposal)
        requester = proposal.requester

        roles = RolePicker.new(requester, proposal)

        expect(roles).to be_requester
      end
    end

    describe "#approver?" do
      it "is true when user is proposal approver" do
        proposal = create(:proposal)
        approver = create(:user)
        create(:approval, user: approver, proposal: proposal)

        roles = RolePicker.new(approver, proposal)

        expect(roles).to be_approver
      end
    end

    describe "#purchaser?" do
      it "is true when user is connected to proposal through purchase step" do
        proposal = create(:proposal)
        purchaser  = create(:user)
        create(:purchase_step, user: purchaser, proposal: proposal)

        roles = RolePicker.new(purchaser, proposal)

        expect(roles).to be_purchaser
      end
    end

    describe "#observer?" do
      it "is true if user is proposal observer" do
        observer = create(:user)
        observation = create(:observation, user: observer)
        proposal = Proposal.find(observation.proposal_id)

        roles = RolePicker.new(observer, proposal)

        expect(roles).to be_observer
      end
    end

    describe "#active_step_user?" do
      it "is true when user is active approver" do
        proposal = create(:proposal)
        approver = create(:user)
        create(:approval, user: approver, proposal: proposal, status: "actionable")

        roles = RolePicker.new(approver, proposal)

        expect(roles).to be_active_step_user
      end

      it "is true when the user is active purchaser" do
        proposal = create(:proposal)
        purchaser = create(:user)
        create(:purchase_step, user: purchaser, proposal: proposal, status: "actionable")

        roles = RolePicker.new(purchaser, proposal)

        expect(roles).to be_active_step_user
      end
    end

    describe "#active_observer?" do
      it "is true when user is observer and not active approver" do
        observer = create(:user)
        observation = create(:observation, user: observer)
        proposal = Proposal.find(observation.proposal_id)

        roles = RolePicker.new(observer, proposal)

        expect(roles).to be_active_observer
      end
    end
  end
end
