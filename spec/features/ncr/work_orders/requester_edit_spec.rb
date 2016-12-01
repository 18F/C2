feature "Requester edits their NCR work order", :js do
  include ProposalSpecHelper

  def requester
    @work_order.requester
  end

  def ncr_proposal
    @work_order.proposal
  end

  before(:each) do
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
  end

  scenario "doesn't change approving list when delegated", :js do
    proposal = Proposal.last
    approval = proposal.individual_steps.first
    delegate_user = create(:user, email_address: "delegate@example.com")
    approval.user.add_delegate(delegate_user)
    approval.update(completer: delegate_user)

    visit edit_ncr_work_order_path(@work_order)
    fill_in "Description", with: "New Description that shouldn't change the approver list"
    click_on "Update"

    expect(page).to have_content(delegate_user.full_name)
  end

  scenario "can change approving official email if first approval not done", :js do
    visit_ncr_request_with_approver

    within(".card-for-observers") do
      expect(page).not_to have_css(".disabled")
    end
  end

  scenario "has a disabled approving official email field if first approval is done", :js do
    @work_order = visit_ncr_request_with_approver
    Capybara.page.driver.browser.resize(940, 3000)
    save_and_open_screenshot

    @work_order.individual_steps.first.complete!
    visit proposal_path(@work_order)
    Capybara.page.driver.browser.resize(940, 3000)
    save_and_open_screenshot

    within(".card-for-observers") do
      expect(page).to have_css(".disabled")
    end
  end

  scenario "can update other fields if first approval is done", :js do
    @work_order.individual_steps.first.complete!
    visit edit_ncr_work_order_path(@work_order)

    fill_in_selectized("ncr_work_order_building_number", Ncr::BUILDING_NUMBERS[1])
    click_on "Update"

    expect(current_path).to eq(proposal_path(ncr_proposal))
    expect(page).to have_content(Ncr::BUILDING_NUMBERS[1])
  end

  scenario "can be edited if completed", :js do
    fully_complete(ncr_proposal)

    visit "/ncr/work_orders/#{@work_order.id}/edit"
    expect(current_path).to eq("/ncr/work_orders/#{@work_order.id}/edit")
  end

  scenario "allows the requester to edit the budget-related fields", :js do
    login_as(@work_order.requester)
    visit proposal_path(@work_order.proposal)

    click_on "MODIFY"

    fill_in 'ncr_work_order[soc_code]', with: "789"
    fill_in 'ncr_work_order[function_code]', with: "PG123"
    fill_in 'ncr_work_order[cl_number]', with: 'CL0000000'
    fill_in 'ncr_work_order[amount]', with: 3.45
    select "Not to exceed", from: "ncr_work_order_not_to_exceed"

    within(".action-bar-container") do
      click_on "SAVE"
      sleep(1)
    end
    within("#card-for-modal") do
      click_on "SAVE"
      sleep(1)
    end

    @work_order.reload
    expect(page).to have_content("PG123")
    expect(page).to have_content("CL0000000")
    expect(page).to have_content("789")
  end
end
