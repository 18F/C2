describe "client_slug confers authz rules", :js do
  include EnvVarSpecHelper

  before(:each) do
    @ncr_user     = create :user, client_slug: "ncr"
    @ncr_approver = create :user, client_slug: "ncr"
    @gsa_user     = create :user, client_slug: "gsa18f"
  end

  it "rejects requests for user with no client_slug" do
    user = create :user, client_slug: ""

    login_as(user)
    visit new_ncr_work_order_path

    expect(page.status_code).to eq(403)
  end

  it "rejects requests for user with different client_slug" do
    login_as(@gsa_user)
    visit new_ncr_work_order_path

    expect(page.status_code).to eq(403)
  end

  it "allows Admin role" do
    user = create(:user, :admin, client_slug: "")

    login_as(user)
    visit new_ncr_work_order_path

    expect(page.status_code).to eq(200)
    submit_ba60_work_order(@ncr_approver)
    expect(page).to have_content("Proposal submitted!")
  end

  it "allows same client_slug to create" do
    user = create(:user, client_slug: "ncr")

    login_as(user)
    visit new_ncr_work_order_path

    expect(page.status_code).to eq(200)
    submit_ba60_work_order(@ncr_approver)
    expect(page).to have_content("Proposal submitted!")
  end

  it "rejects different client_slug from viewing existing proposal" do
    nil_user = create(:user, client_slug: "")

    login_as(@ncr_user)
    visit new_ncr_work_order_path
    submit_ba60_work_order(@ncr_approver)
    proposal_path = current_path
    login_as(nil_user)
    visit proposal_path
    expect(page.status_code).to eq(403)
  end

  it "rejects same client_slug non-subscriber to view existing proposal" do
    ncr_user2 = create(:user, client_slug: "ncr")

    login_as(@ncr_user)
    visit new_ncr_work_order_path
    submit_ba60_work_order(@ncr_approver)
    proposal_path = current_path
    login_as(ncr_user2)
    visit proposal_path

    expect(page.status_code).to eq(403)
  end

  it "rejects subscriber trying to add user with non-client_slug as observer" do
    login_as(@ncr_user)

    visit new_ncr_work_order_path
    submit_ba60_work_order(@ncr_approver)

    expect(page.status_code).to eq(200)
    expect_to_not_find_amongst_select_tag_options("observation_user_id", @gsa_user.email_address)
  end

  scenario "load 18f new request page in beta view" do
    with_env_var("BETA_FEATURE_LIST_VIEW", "true") do
      user = @gsa_user
      login_as(@gsa_user)
      user.add_role(ROLE_BETA_USER)
      user.add_role(ROLE_BETA_ACTIVE)
      visit new_gsa18f_procurement_path
      expect(page).to have_content("Request details")
    end
  end

  scenario "load ncr new request page in beta view" do
    with_env_var("BETA_FEATURE_LIST_VIEW", "true") do
      user = @ncr_user
      login_as(@ncr_user)
      user.add_role(ROLE_BETA_USER)
      user.add_role(ROLE_BETA_ACTIVE)
      visit new_ncr_work_order_path
      expect(page).to have_content("Request details")
    end
  end

  private

  def submit_ba60_work_order(approver)
    fill_in "Project title", with: "blue shells"
    fill_in "Description", with: "desc content"
    choose "BA60"
    fill_in_selectized("ncr_work_order_vendor", "Yoshi")
    fill_in "Amount", with: 123.45
    
    fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
    fill_in_selectized("ncr_work_order_building_number", Ncr::BUILDING_NUMBERS[0])
    find('input[name="commit"]').click
  end

  def add_as_observer(user)
    select user.email_address, from: "observation_user_id"
    fill_in "observation_reason", with: "observe thy ways"
    click_on "Add an Observer"
  end

  def expect_to_not_find_amongst_select_tag_options(field_name, value)
    expect(field_labeled(field_name).first(:xpath, ".//option[text() = '#{value}']")).to_not be_present
  end
end
