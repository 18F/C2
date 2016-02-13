describe ProposalQuery do
  describe "#step_users" do
    it "returns users for all individual steps" do
      user = create(:user)
      proposal = create(:proposal, :with_approver, approver_user: user)

      users = ProposalQuery.new(proposal).step_users

      expect(users).to match_array([user])
    end
  end

  describe "#approvers" do
    it "returns users for approval steps" do
      proposal = create(:proposal, :with_approval_and_purchase)
      approval_step = proposal.approval_steps.first

      users = ProposalQuery.new(proposal).approvers

      expect(users).to match_array([approval_step.user])
    end
  end

  describe "#purchasers" do
    it "returns users for purchase steps" do
      proposal = create(:proposal, :with_approval_and_purchase)
      purchase_step = proposal.purchase_steps.first

      users = ProposalQuery.new(proposal).purchasers

      expect(users).to match_array([purchase_step.user])
    end
  end

  describe "#user_delegates" do
    it "returns user delegations for step users" do
      user = create(:user)
      proposal = create(:proposal, delegate: user)
      other_user = create(:user)
      create(:proposal, delegate: other_user)

      user_delegates = ProposalQuery.new(proposal).user_delegates

      expect(user_delegates).to match_array(user.incoming_delegations)
    end
  end

  describe "#delegates" do
    it "returns the assignees for the delegations" do
      user = create(:user)
      other_user = create(:user)
      proposal = create(:proposal, delegate: user)
      create(:approval_step, user: other_user, proposal: proposal)

      users = ProposalQuery.new(proposal).delegates

      expect(users).to match_array([user])
    end
  end
end
