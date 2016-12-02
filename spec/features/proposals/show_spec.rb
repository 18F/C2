describe 'View a proposal' do
  include ProposalSpecHelper
  
  let(:user) { create(:user) }
  let(:proposal) { create(:proposal, requester: user) }

  it "displays a warning message when editing a fully-approved proposal", :js do
    work_order = create(:ncr_work_order, :with_approvers)
    requester = work_order.proposal.requester
    login_as(requester)
    fully_complete(work_order.proposal)
    visit proposal_path(work_order.proposal)
    expect(page).to have_content("Wait! You're about to change an approved request. Your changes will be logged and sent to approvers, and your action may require reapproval of the request.")
  end
end
