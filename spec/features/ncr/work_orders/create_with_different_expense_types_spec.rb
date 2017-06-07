feature "Create NCR Work orders with different expense types", :js do
  scenario "hides fields based on expense" do
    requester = create(:user, client_slug: "ncr")
    login_as(requester)
    visit new_ncr_work_order_path

    expect(page).to have_no_field("RWA#")
    expect(page).to have_no_field("Work Order")
    expect(page).to have_no_field("emergency")

    choose "BA61"
    expect(page).to have_no_field("RWA#")
    expect(page).to have_no_field("Work Order")
    expect(page).to have_field("emergency")
    expect(find_field("emergency", visible: false)).to be_visible

    choose "BA80"
    expect(page).to have_field("RWA#")
    expect(page).to have_field("Work Order / Ticket #")
    expect(page).to have_no_field("emergency")
    expect(find_field("RWA#")).to be_visible
  end

  context "BA61 emergency request" do
    scenario "approves request automatically" do
      approver = create(:user, client_slug: "ncr")
      requester = create(:user, client_slug: "ncr")
      login_as(requester)
      visit new_ncr_work_order_path

      fill_in "Project title", with: "Test project title"
      choose "BA61"
      check "This request was an emergency and I received a verbal Notice to Proceed (NTP)"
      fill_in_selectized("ncr_work_order_building_number", "Test Building")
      fill_in_selectized("ncr_work_order_vendor", "Test vendor")
      fill_in "Amount", with: 123.45
      fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
      click_on "SUBMIT"
      expect(page).to have_content("Proposal submitted")
      expect(page).to have_content("This request was an emergency and received a verbal Notice to Proceed (NTP)")
    end
  end

  context "BA61 emergency request selected and then unselected" do
    scenario "request is not set as emergency" do
      approver = create(:user, client_slug: "ncr")
      requester = create(:user, client_slug: "ncr")
      login_as(requester)
      visit new_ncr_work_order_path

      fill_in "Project title", with: "Test project title"
      choose "BA61"
      check "This request was an emergency and I received a verbal Notice to Proceed (NTP)"
      choose "BA60"
      fill_in_selectized("ncr_work_order_building_number", "Test Building")
      fill_in_selectized("ncr_work_order_vendor", "Test vendor")
      fill_in "Amount", with: 123.45
      fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
      click_on "SUBMIT"
      expect(page).to have_content("Proposal submitted")
      expect(page).to have_content("Step 1")
      expect(page).to have_content("Approver Pending")
      expect(page).to_not have_content("Step 2")
    end
  end

  context "expense type is BA60" do
    scenario "building id is not required" do
      requester = create(:user, client_slug: "ncr")
      login_as(requester)
      visit new_ncr_work_order_path
      select_expense_type("ba60")
      find("#ncr_work_order_expense_type_ba60").click
      expect_building_id_not_to_be_required
    end
  end

  context "expense type is not BA60" do
    scenario "building id is required" do
      requester = create(:user, client_slug: "ncr")
      login_as(requester)
      visit new_ncr_work_order_path
      ["ba61", "ba80"].each do |expense_type|
        select_expense_type(expense_type)
        expect_building_id_to_be_required
      end
    end
  end

  context "selects BA60 and then unselects BA60" do
    scenario "building id is required" do
      requester = create(:user, client_slug: "ncr")
      login_as(requester)
      visit new_ncr_work_order_path
      select_expense_type("ba60")
      select_expense_type("ba80")
      expect_building_id_to_be_required
    end
  end

  def select_expense_type(expense_type)
    find("#ncr_work_order_expense_type_#{expense_type}").click
  end

  def expect_building_id_not_to_be_required
    expect(find('.ncr_work_order_building_number input')['class']).to_not match('required')
  end

  def expect_building_id_to_be_required
    expect(find('.ncr_work_order_building_number input')['class']).to match('required')
  end
end
