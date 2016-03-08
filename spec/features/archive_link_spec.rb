feature "Archive link" do
  scenario "displays archive link when more than limit" do
    ClimateControl.modify CLOSED_PROPOSAL_LIMIT: "2" do
      user = create(:user)
      approver = create(:user)
      2.times.map do |i|
        wo = create(:ncr_work_order, requester: user)
        approval = create(:approval_step, proposal: wo.proposal, user: approver, status: "actionable")
        approval.complete!
      end

      login_as(user)
      visit proposals_path

      expect(page).to have_content("View the archive")
    end
  end

  scenario "hides archive link when less than or equal to limit" do
    ClimateControl.modify CLOSED_PROPOSAL_LIMIT: "2" do
      user = create(:user)
      approver = create(:user)
      wo = create(:ncr_work_order, requester: user)
      approval = create(:approval_step, proposal: wo.proposal, user: approver, status: "actionable")
      approval.complete!

      login_as(user)
      visit proposals_path

      expect(page).to_not have_content("View the archive")
    end
  end
end
