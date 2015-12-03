feature "Proposals index" do
  include ProposalTableSpecHelper

  scenario "filters pending proposals according to current_user" do
    user = create(:user)
    _reviewable_proposals = create_list(:proposal, 2, observer: user)
    _pending_proposals = create_list(:proposal, 2, :with_approver, approver_user: user)
    _cancelled = create_list(:proposal, 2, status: "cancelled", observer: user)

    login_as(user)
    visit proposals_path
    tables = page.all('.tabular-data')

    expect(tables[0].text).to have_content('Please review')
    expect(tables[1].text).to have_content('Waiting for review')
    expect(tables[2].text).to have_content('Cancelled')
  end

  scenario "defaults to sorted by created date" do
    user = create(:user)
    proposals = create_list(:proposal, 2, observer: user)
    cancelled = create_list(:proposal, 2, status: "cancelled", observer: user)

    login_as(user)
    visit proposals_path

    within(reviewable_proposals_section) do
      expect(find("th.desc")).to have_content "Submitted"
    end

    expect_order(reviewable_proposals_section, proposals.reverse)

    within(pending_proposals_section) do
      expect(find("th.desc")).to have_content "Submitted"
    end

    expect_order(pending_proposals_section, cancelled.reverse)
  end
end
