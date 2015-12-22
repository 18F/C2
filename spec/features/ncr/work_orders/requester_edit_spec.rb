feature "Requester edits their NCR work order", :js do
  include ProposalSpecHelper

  let(:organization) { create(:ncr_organization) }
  let(:work_order) do
    create(
      :ncr_work_order,
      building_number: Ncr::BUILDING_NUMBERS[0],
      org_code: organization.code_and_name,
      vendor: "test vendor",
      description: "test"
    )
  end
  let(:ncr_proposal) { work_order.proposal }
  let(:requester) { work_order.requester }

  before do
    work_order.setup_approvals_and_observers
    login_as(requester)
  end

  scenario "preserves previously selected values in dropdowns" do
    visit edit_ncr_work_order_path(work_order)

    expect_page_to_have_selected_selectize_option(
      "ncr_work_order_building_number",
      Ncr::BUILDING_NUMBERS[0]
    )
    expect_page_to_have_selected_selectize_option(
      "ncr_work_order_org_code",
      organization.code_and_name
    )
    expect_page_to_have_selected_selectize_option(
      "ncr_work_order_vendor",
      "test vendor"
    )
    expect_page_to_have_selected_selectize_option(
      "ncr_work_order_approving_official_email",
      work_order.approving_official_email
    )
  end

  scenario "creates a comment when editing" do
    new_org = create(:ncr_organization, code: "XZP", name: "Test test")
    visit edit_ncr_work_order_path(work_order)

    fill_in "Description", with: "New Description"
    fill_in_selectized("ncr_work_order_building_number", Ncr::BUILDING_NUMBERS[1])
    fill_in_selectized("ncr_work_order_org_code", new_org.code_and_name)
    click_on "Update"

    expect(page).to have_content("Request modified by")
    expect(page).to have_content("Description was changed from test to New Description")
    expect(page).to have_content(
      "Building number was changed from #{Ncr::BUILDING_NUMBERS[0]} to #{Ncr::BUILDING_NUMBERS[1]}"
    )
    expect(page).to have_content(
      "Org code was changed from #{organization.code_and_name} to #{new_org.code_and_name}"
    )
  end

  scenario "notifies observers of changes" do
    work_order.add_observer('observer@example.com')
    visit edit_ncr_work_order_path(work_order)

    fill_in "Description", with: "Observer changes"
    click_on "Update"

    expect(deliveries.length).to eq(2)
    expect(deliveries.last).to have_content("observer@example.com")
  end

  scenario "does not resave unchanged requests" do
    visit edit_ncr_work_order_path(work_order)
    click_on "Update"

    expect(current_path).to eq("/proposals/#{work_order.proposal.id}")
    expect(page).to have_content("No changes were made to the request")
    expect(deliveries.length).to eq(0)
  end

  scenario "allows requester to change the approving official" do
    approver = create(:user, client_slug: "ncr")
    old_approver = ncr_proposal.approvers.first
    expect(Dispatcher).to receive(:on_approver_removal).with(ncr_proposal, [old_approver])
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in_selectized("ncr_work_order_approving_official_email", approver.email_address)
    click_on "Update"

    proposal = Proposal.last
    expect(proposal.approvers.first.email_address).to eq approver.email_address
    expect(proposal.individual_steps.first).to be_actionable
  end

  scenario "allows requester to change the expense type" do
    visit edit_ncr_work_order_path(work_order)

    choose "BA80"
    fill_in "RWA Number", with: "a1234567"
    click_on "Update"

    proposal = Proposal.last
    expect(proposal.approvers.length).to eq(2)
    expect(proposal.approvers.second.email_address).to eq(Ncr::Mailboxes.ba80_budget)
  end

  context "proposal changes from BA80 to BA61" do
    scenario "removed tier 1 approver is notified if approval is not pending" do
      work_order.update(expense_type: "BA61")
      role_name = "BA61_tier1_budget_approver"
      tier_one_approver = User.with_role(role_name).first
      approval = tier_one_approver.steps.where(proposal: ncr_proposal).first
      approval.update(status: "actionable")

      visit "/ncr/work_orders/#{work_order.id}/edit"
      choose "BA80"
      fill_in "RWA Number", with: "a1234567"
      click_on "Update"

      expect(deliveries.count do |email|
        email.to.first == tier_one_approver.email_address
      end).to eq 1
    end
  end

  scenario "doesn't change approving list when delegated" do
    proposal = Proposal.last
    approval = proposal.individual_steps.first
    approval.approve!
    approval = proposal.individual_steps.second
    user = approval.user
    delegate = User.new(email_address: "delegate@example.com")
    delegate.save
    user.add_delegate(delegate)
    approval.update_attributes!(user: delegate)

    visit edit_ncr_work_order_path(work_order)
    fill_in "Description", with: "New Description that shouldn't change the approver list"
    click_on "Update"

    expect(page).to have_content("delegate@example.com")
  end

  scenario "has 'Discard Changes' link" do
    visit edit_ncr_work_order_path(work_order)

    click_link "Discard Changes"

    expect(current_path).to eq(proposal_path(ncr_proposal))
  end

  scenario "can change approving official email if first approval not done" do
    visit edit_ncr_work_order_path(work_order)

    within(".ncr_work_order_approving_official_email") do
      expect(page).not_to have_css(".disabled")
    end
  end

  scenario "has a disabled approving official email field if first approval is done" do
    work_order.individual_steps.first.approve!

    visit edit_ncr_work_order_path(work_order)

    within(".ncr_work_order_approving_official_email") do
      expect(page).to have_css(".disabled")
    end
  end

  scenario "can update other fields if first approval is done" do
    work_order.individual_steps.first.approve!
    visit edit_ncr_work_order_path(work_order)

    fill_in_selectized("ncr_work_order_building_number", Ncr::BUILDING_NUMBERS[1])
    click_on "Update"

    expect(current_path).to eq(proposal_path(ncr_proposal))
    expect(page).to have_content(Ncr::BUILDING_NUMBERS[1])
  end

  scenario "can be edited if approved" do
    fully_approve(ncr_proposal)

    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(current_path).to eq("/ncr/work_orders/#{work_order.id}/edit")
  end

  scenario "allows the requester to edit the budget-related fields" do
    visit "/ncr/work_orders/#{work_order.id}/edit"

    fill_in "CL number", with: "CL1234567"
    fill_in "Function code", with: "PG123"
    fill_in "Object field / SOC code", with: "789"
    click_on "Update"

    work_order.reload
    expect(work_order.cl_number).to eq("CL1234567")
    expect(work_order.function_code).to eq("PG123")
    expect(work_order.soc_code).to eq("789")
  end

  scenario "disables the emergency field" do
    visit edit_ncr_work_order_path(work_order)

    within(".ncr_work_order_emergency") do
      expect(page).to have_css(".disabled")
    end
  end
end
