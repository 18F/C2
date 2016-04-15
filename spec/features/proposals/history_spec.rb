describe 'View history for a proposal' do
  it "displays the model information" do
    user = create(:user)
    PaperTrail.whodunnit = user.id.to_s
    proposal = create(:proposal, requester: user)
    login_as(user)

    visit history_proposal_path(proposal)

    expect(page).to have_content('Proposal')
  end

  describe "History diffs" do
    it "correctly shows changes per user" do
      ncr_work_order = create(:ncr_work_order, :with_approvers)
      proposal = ncr_work_order.proposal
      requester = ncr_work_order.requester

      edit_path = edit_ncr_work_order_path(ncr_work_order)

      login_as(requester)
      visit edit_path
      fill_in "Description", with: "changed by requester"
      click_on "Update"

      approver = ncr_work_order.approvers.first
      login_as(approver)
      visit proposal_path(proposal)
      click_on "Approve"

      expect(current_path).to eq(proposal_path(proposal))
      expect(page).to have_content("You have approved #{proposal.public_id}")

      visit edit_path
      fill_in "Description", with: "changed by approver"
      click_on "Update"

      expect(current_path).to eq(proposal_path(proposal))
      expect(page).to have_content("changed by approver")

      visit history_proposal_path(proposal)
      expect(page).to have_content("changed by approver")
    end
  end
end
