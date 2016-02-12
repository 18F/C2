describe "Archive link" do
  with_env_vars(CLOSED_PROPOSAL_LIMIT: '2') do
    it "displays archive link when more than limit" do
      user = create(:user)
      approver = create(:user)
      2.times.map do |i|
        wo = create(:ncr_work_order, requester: user)
        approval = create(:approval_step, proposal: wo.proposal, user: approver, status: "actionable")
        approval.approve!
      end

      login_as(user)
      visit proposals_path

      expect(page).to have_content("View the archive")
    end

    it "hides archive link when less than or equal to limit" do
      user = create(:user)
      approver = create(:user)
      wo = create(:ncr_work_order, requester: user)
      approval = create(:approval_step, proposal: wo.proposal, user: approver, status: "actionable")
      approval.approve!

      login_as(user)
      visit proposals_path

      expect(page).to_not have_content("View the archive")
    end
  end
end
