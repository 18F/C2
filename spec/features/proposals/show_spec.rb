describe 'View a proposal' do
  include ProposalSpecHelper
  
  let(:user) { create(:user) }
  let(:proposal) { create(:proposal, requester: user) }

  it "displays a warning message when editing a fully-approved proposal", :js do
    approver = create(:user, client_slug: "ncr")
    organization = create(:ncr_organization)
    project_title = "buying stuff"
    requester = create(:user, client_slug: "ncr")

    login_as(requester)

    visit new_ncr_work_order_path
    fill_in 'Project title', with: project_title
    fill_in 'Description', with: "desc content"
    choose 'BA80'
    fill_in 'RWA#', with: 'F1234567'
    fill_in_selectized("ncr_work_order_building_number", "Test building")
    fill_in_selectized("ncr_work_order_vendor", "ACME")
    fill_in 'Amount', with: 123.45
    fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
    fill_in_selectized("ncr_work_order_ncr_organization", organization.code_and_name)
    click_on "SUBMIT"

    proposal = requester.proposals.last

    visit proposal_path(proposal)
    
    fully_complete(proposal)
    visit proposal_path(proposal)
    expect(page).to have_content("Wait! You're about to change an approved request. Your changes will be logged and sent to approvers, and your action may require reapproval of the request.")
  end
end
