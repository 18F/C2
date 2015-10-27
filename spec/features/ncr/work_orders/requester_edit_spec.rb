feature 'Requester edits their NCR work order' do
  around(:each) do |example|
    with_env_var('DISABLE_SANDBOX_WARNING', 'true') do
      example.run
    end
  end

  let(:work_order) { create(:ncr_work_order, description: 'test') }
  let(:ncr_proposal) { work_order.proposal }
  let!(:approver) { create(:user, client_slug: 'ncr') }

  before do
    approver = create(:user, email_address: 'approver@example.com', client_slug: 'ncr')
    work_order.setup_approvals_and_observers(approver.email_address)
    login_as(work_order.requester)
  end

  scenario 'can be edited if pending' do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(find_field("ncr_work_order_building_number").value).to eq(
      Ncr::BUILDING_NUMBERS[0])
    fill_in 'Vendor', with: 'New ACME'
    click_on 'Update'
    expect(current_path).to eq("/proposals/#{ncr_proposal.id}")
    expect(page).to have_content("New ACME")
    expect(page).to have_content("modified")
    # Verify it is actually saved
    work_order.reload
    expect(work_order.vendor).to eq("New ACME")
  end

  scenario 'creates a special comment when editing' do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Vendor', with: "New Test Vendor"
    fill_in 'Description', with: "New Description"
    click_on 'Update'

    expect(page).to have_content("Request modified by")
    expect(page).to have_content("Description was changed from test to New Description")
    expect(page).to have_content("Vendor was changed from Some Vend to New Test Vendor")
  end

  scenario 'notifies observers of changes' do
    work_order.add_observer('observer@example.com')
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Description', with: "Observer changes"
    click_on 'Update'

    expect(deliveries.length).to eq(2)
    expect(deliveries.last).to have_content('observer@example.com')
  end

  scenario 'does not resave unchanged requests' do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    click_on 'Update'

    expect(current_path).to eq("/proposals/#{work_order.proposal.id}")
    expect(page).to have_content("No changes were made to the request")
    expect(deliveries.length).to eq(0)
  end

  scenario 'allows requester to change the approving official' do
    approver = create(:user, client_slug: 'ncr')
    old_approver = ncr_proposal.approvers.first
    expect(Dispatcher).to receive(:on_approver_removal).with(ncr_proposal, [old_approver])
    visit "/ncr/work_orders/#{work_order.id}/edit"
    select approver.email_address, from: "Approving official's email address"
    click_on 'Update'
    proposal = Proposal.last

    expect(proposal.approvers.first.email_address).to eq approver.email_address
    expect(proposal.individual_approvals.first).to be_actionable
  end

  scenario "allows requester to change the expense type" do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    choose "BA80"
    fill_in "RWA Number", with: "a1234567"
    click_on "Update"
    proposal = Proposal.last
    expect(proposal.approvers.length).to eq(2)
    expect(proposal.approvers.second.email_address).to eq(Ncr::WorkOrder.ba80_budget_mailbox)
  end

  context "proposal changes from BA80 to BA61" do
    scenario "removed tier 1 approver is notified if approval is not pending" do
      work_order.update(expense_type: "BA61")
      role = "BA61_tier1_budget_approver"
      tier_one_approver = User.with_role(role).first
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
    approval = proposal.individual_approvals.first
    approval.approve!
    approval = proposal.individual_approvals.second
    user = approval.user
    delegate = User.new(email_address: 'delegate@example.com')
    delegate.save
    user.add_delegate(delegate)
    approval.update_attributes!(user: delegate)
    visit "/ncr/work_orders/#{work_order.id}/edit"
    fill_in 'Description', with: "New Description that shouldn't change the approver list"
    click_on 'Update'

    proposal.reload
    second_approver = proposal.approvers.second.email_address
    expect(second_approver).to eq('delegate@example.com')
    expect(proposal.individual_approvals.length).to eq(3)
  end

  scenario "has 'Discard Changes' link" do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(page).to have_content("Discard Changes")
    click_on "Discard Changes"
    expect(current_path).to eq("/proposals/#{work_order.proposal.id}")
  end

  scenario 'has a disabled field if first approval is done' do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(find("[name=approver_email]")["disabled"]).to be_nil
    work_order.individual_approvals.first.approve!
    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(find("[name=approver_email]")["disabled"]).to eq("disabled")
    # And we can still submit
    fill_in 'Vendor', with: 'New ACME'
    click_on 'Update'
    expect(current_path).to eq("/proposals/#{ncr_proposal.id}")
    # Verify it is actually saved
    work_order.reload
    expect(work_order.vendor).to eq("New ACME")
  end

  scenario 'can be edited if approved' do
    ncr_proposal.update_attributes(status: 'approved') # avoid workflow

    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(current_path).to eq("/ncr/work_orders/#{work_order.id}/edit")
  end

  scenario 'provides the previous building when editing', :js do
    work_order.update(building_number: "BillDing, street")
    visit "/ncr/work_orders/#{work_order.id}/edit"
    click_on "Update"
    expect(current_path).to eq("/proposals/#{ncr_proposal.id}")
    expect(work_order.reload.building_number).to eq("BillDing, street")
  end

  scenario 'allows the requester to edit the budget-related fields' do
    visit "/ncr/work_orders/#{work_order.id}/edit"

    fill_in 'CL number', with: 'CL1234567'
    fill_in 'Function code', with: 'PG123'
    fill_in 'Object field / SOC code', with: '789'
    click_on 'Update'

    work_order.reload
    expect(work_order.cl_number).to eq('CL1234567')
    expect(work_order.function_code).to eq('PG123')
    expect(work_order.soc_code).to eq('789')
  end

  scenario 'disables the emergency field' do
    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(find_field('emergency', disabled: true)).to be_disabled
  end
end
