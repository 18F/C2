feature "Requester edits their NCR work order", :js do
  include ProposalSpecHelper

  def requester
    @work_order.requester
  end

  def ncr_proposal
    @work_order.proposal
  end

  def create_new_proposal
    approver = create(:user, client_slug: "ncr")
    organization = create(:ncr_organization)
    requester = create(:user, client_slug: "ncr")
    login_as(requester)
    visit new_ncr_work_order_path
    fill_in 'Project title', with: "Buying stuff"
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
    requester
  end

  def save_update
    within(".action-bar-container") do
      click_on "SAVE"
      sleep(1)
    end
    within("#card-for-modal") do
      click_on "SAVE"
      sleep(1)
    end
  end

  scenario "can update other fields if first approval is done", :js do
    requester = create_new_proposal
    proposal = requester.proposals.last
    proposal.individual_steps.first.complete!
    visit proposal_path(proposal)

    click_on "MODIFY"
    fill_in 'ncr_work_order[description]', with: "New desc content"
    save_update

    expect(current_path).to eq(proposal_path(proposal))
    expect(page).to have_content("New desc content")
  end

  scenario "can be edited if completed", :js do
    requester = create_new_proposal
    proposal = requester.proposals.last

    fully_complete(proposal)
    visit proposal_path(proposal)
    
    click_on "MODIFY"
    fill_in 'ncr_work_order[description]', with: "New desc content"
    save_update

    expect(page).to have_content("New desc content")
  end

  scenario "allows the requester to edit the budget-related fields", :js do
    @organization = create(:ncr_organization)
    @work_order = create(
      :ba61_ncr_work_order,
      building_number: Ncr::BUILDING_NUMBERS[0],
      ncr_organization: @organization,
      vendor: "test vendor",
      description: "test"
    )
    unless @logged_in_once
      @work_order.setup_approvals_and_observers
      login_as(requester)
      @logged_in_once = true
    end

    login_as(@work_order.requester)
    visit proposal_path(@work_order.proposal)

    click_on "MODIFY"

    fill_in 'ncr_work_order[soc_code]', with: "789"
    fill_in 'ncr_work_order[function_code]', with: "PG123"
    fill_in 'ncr_work_order[cl_number]', with: 'CL0000000'

    save_update

    @work_order.reload
    expect(page).to have_content("PG123")
    expect(page).to have_content("CL0000000")
    expect(page).to have_content("789")
  end
end
