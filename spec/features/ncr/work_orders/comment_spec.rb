feature 'Delegates for NCR work order' do
  let(:work_order) { create(:ncr_work_order, description: 'test') }
  let(:proposal) { work_order.proposal }
  let(:delegate) { create(:user, client_slug: "ncr") }

  scenario 'adds current user to the observers list when commenting' do
    work_order.setup_approvals_and_observers
    approver = proposal.approvers.first
    approver.add_delegate(delegate)
    login_as(delegate)

    visit "/proposals/#{proposal.id}"
    fill_in "comment_comment_text", with: "comment text"
    click_on "Send a Comment"

    expect(page).to have_content("comment text")
    expect(proposal.observers).to include(delegate)
  end
end
