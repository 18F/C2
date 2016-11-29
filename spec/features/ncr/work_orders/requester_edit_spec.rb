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

  scenario "does not resave unchanged requests", :email do
    visit edit_ncr_work_order_path(@work_order)
    click_on "Update"

    expect(current_path).to eq(proposal_path(@work_order.proposal))
    expect(page).to have_content("No changes were made to the request.")
    expect(deliveries.length).to eq(0)
  end

  scenario "allows requester to change the approving official", :js do
    approver = create(:user, client_slug: "ncr")

    visit "/ncr/work_orders/#{@work_order.id}/edit"
    fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
    click_on "Update"

    proposal = Proposal.last
    expect(proposal.approvers.first.email_address).to eq approver.email_address
    expect(proposal.individual_steps.first).to be_actionable
  end

  scenario "allows requester to change the expense type", :js do
    visit edit_ncr_work_order_path(@work_order)

    choose "BA80"
    fill_in "RWA Number", with: "a1234567"
    click_on "Update"

    proposal = Proposal.last
    expect(proposal.approvers.length).to eq(2)
    expect(proposal.approvers.second.email_address).to eq(Ncr::Mailboxes.ba80_budget.email_address)
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

  scenario "has 'Discard Changes' link", :js do
    visit edit_ncr_work_order_path(@work_order)

    click_link "Discard Changes"

    expect(page).to have_current_path(proposal_path(ncr_proposal))
  end

  scenario "can change approving official email if first approval not done", :js do
    visit edit_ncr_work_order_path(@work_order)

    within(".ncr_work_order_approving_official") do
      expect(page).not_to have_css(".disabled")
    end
  end

  scenario "has a disabled approving official email field if first approval is done", :js do
    @work_order.individual_steps.first.complete!

    visit edit_ncr_work_order_path(@work_order)

    within(".ncr_work_order_approving_official") do
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
    visit "/ncr/work_orders/#{@work_order.id}/edit"

    fill_in "CL number", with: "CL1234567"
    fill_in "Function code", with: "PG123"
    fill_in "Object field / SOC code", with: "789"
    click_on "Update"

    @work_order.reload
    expect(@work_order.cl_number).to eq("CL1234567")
    expect(@work_order.function_code).to eq("PG123")
    expect(@work_order.soc_code).to eq("789")
  end

  scenario "disables the emergency field", :js do
    visit edit_ncr_work_order_path(@work_order)

    within(".ncr_work_order_emergency") do
      expect(page).to have_css(".disabled")
      checkbox = page.find("input[type=checkbox]")
      expect(checkbox["class"]).to include("respect-disabled")
      expect(checkbox["disabled"]).to eq(true)
    end
  end
end
