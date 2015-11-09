describe "client_slug confers authz rules" do
  it "rejects requests for user with no client_slug" do
    user = create(:user, client_slug: '')
    login_as(user)
    visit '/ncr/work_orders/new'
    expect(page.status_code).to eq(403)
  end

  it "rejects requests for user with different client_slug" do
    user = create(:user, client_slug: 'gsa18f')
    login_as(user)
    visit '/ncr/work_orders/new'
    expect(page.status_code).to eq(403)
  end

  it "allows Admin role" do
    user = create(:user, :admin, client_slug: '')
    approver = create(:user, client_slug: "ncr")
    login_as(user)
    visit '/ncr/work_orders/new'
    expect(page.status_code).to eq(200)
    submit_ba60_work_order(approver)
    expect(page).to have_content('Proposal submitted!')
  end

  it "allows same client_slug to create" do
    user = create(:user, client_slug: "ncr")
    approver = create(:user, client_slug: "ncr")
    login_as(user)
    visit '/ncr/work_orders/new'
    expect(page.status_code).to eq(200)
    submit_ba60_work_order(approver)
    expect(page).to have_content('Proposal submitted!')
  end

  it "rejects different client_slug from viewing existing proposal" do
    ncr_user = create(:user, client_slug: "ncr")
    nil_user = create(:user, client_slug: '')
    approver = create(:user, client_slug: "ncr")
    login_as(ncr_user)
    visit '/ncr/work_orders/new'
    submit_ba60_work_order(approver)
    proposal_path = current_path
    login_as(nil_user)
    visit proposal_path
    expect(page.status_code).to eq(403)
  end

  it "rejects same client_slug non-subscriber to view existing proposal" do
    ncr_user = create(:user, client_slug: "ncr")
    ncr_user2 = create(:user, client_slug: "ncr")
    approver = create(:user, client_slug: "ncr")
    login_as(ncr_user)
    visit '/ncr/work_orders/new'
    submit_ba60_work_order(approver)
    proposal_path = current_path
    login_as(ncr_user2)
    visit proposal_path
    expect(page.status_code).to eq(403)
  end

  it "rejects subscriber trying to add user with non-client_slug as observer" do
    ncr_user = create(:user, client_slug: "ncr")
    gsa_user = create(:user, client_slug: 'gsa18f')
    approver = create(:user, client_slug: "ncr")
    login_as(ncr_user)
    visit '/ncr/work_orders/new'
    submit_ba60_work_order(approver)
    proposal_path = current_path
    visit proposal_path
    expect(page.status_code).to eq(200)
    expect_to_not_find_amongst_select_tag_options('observation_user_email_address', gsa_user.email_address)
  end

  private

  def submit_ba60_work_order(approver)
    fill_in 'Project title', with: "blue shells"
    fill_in 'Description', with: "desc content"
    choose 'BA60'
    fill_in 'Vendor', with: 'Yoshi'
    fill_in 'Amount', with: 123.45
    select approver.email_address, from: "Approving official's email address"
    fill_in 'Building number', with: Ncr::BUILDING_NUMBERS[0]
    select Ncr::Organization.all[0], from: 'ncr_work_order_org_code'
    find('input[name="commit"]').click
  end

  def add_as_observer(user)
    select user.email_address, from: 'observation_user_email_address'
    fill_in "observation_reason", with: "observe thy ways"
    click_on 'Add an Observer'
  end

  def expect_to_not_find_amongst_select_tag_options(field_name, value)
    expect(field_labeled(field_name).first(:xpath, ".//option[text() = '#{value}']")).to_not be_present
  end
end
