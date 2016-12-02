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
    it "correctly shows changes per user", :js do
      ncr_work_order = create(:ncr_work_order, :with_approvers)
      proposal = ncr_work_order.proposal
      requester = ncr_work_order.requester

      login_as(requester)
      visit proposal_path(proposal)
      click_on 'MODIFY'
      fill_in "Description", with: "changed by requester"
      click_on "SAVE"
      sleep(1)
      within("#modal-el-1") do 
        click_on "SAVE"
      end
      sleep(1)

      approver = ncr_work_order.approvers.first
      login_as(approver)
      visit proposal_path(proposal)
      click_on "Approve"

      expect(current_path).to eq(proposal_path(proposal))
      expect(page).to have_content("You have approved #{proposal.public_id}")

      click_on 'MODIFY'
      fill_in "Description", with: "changed by approver"
      click_on "SAVE"
      sleep(1)
      within("#modal-el-1") do 
        click_on "SAVE"
      end
      sleep(1)

      expect(current_path).to eq(proposal_path(proposal))
      expect(page).to have_content("changed by approver")

      within("#card-for-activity") do
        expect(page).to have_content("changed by approver")
      end
    end
  end
end
