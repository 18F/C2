feature "Proposals index" do
  include ProposalTableSpecHelper

  scenario "filters pending proposals according to current_user" do
    user = create(:user)
    _reviewable_proposals = create_list(:proposal, 2, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _cancelled = create_list(:proposal, 2, status: "cancelled", observer: user)

    login_as(user)
    visit proposals_path

    expect(reviewable_proposals_table).to have_content('Please review')
    expect(pending_proposals_table).to have_content('Waiting for review')
    expect(cancelled_proposals_table).to have_content('Cancelled')
  end

  scenario "defaults to sorted by created date" do
    user = create(:user)
    proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    cancelled = create_list(:proposal, 2, :with_approver, status: "cancelled", approver_user: user)

    login_as(user)
    visit proposals_path

    expect_order(reviewable_proposals_table, proposals.reverse)
    expect_order(cancelled_proposals_table, cancelled.reverse)
  end

  context "proposals needing review" do
    scenario "shows proposals in needs review section" do
      user = create(:user)
      proposal = create(:proposal, :with_approver, approver_user: user)
      login_as(user)

      visit proposals_path

      expect(page).to have_content("Purchase Requests Needing Review")
      within(reviewable_proposals_section) do
        expect(page).to have_content proposal.public_id
      end
    end
  end

  context "no proposals pending review" do
    scenario "needing review section is hidden" do
      user = create(:user)
      login_as(user)

      visit proposals_path

      expect(page).not_to have_content("Purchase Requests Needing Review")
    end
  end
end
