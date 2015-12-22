feature "Creating an NCR work order", :js do
  context "when signed in as an NCR user" do
    scenario "saves a Proposal with the attributes" do
      approver = create(:user, client_slug: "ncr")
      organization = create(:ncr_organization)
      project_title = "buying stuff"
      login_as(requester)

      visit new_ncr_work_order_path
      fill_in 'Project title', with: project_title
      fill_in 'Description', with: "desc content"
      choose 'BA80'
      fill_in 'RWA Number', with: 'F1234567'
      fill_in_selectized("ncr_work_order_building_number", "Test building")
      fill_in_selectized("ncr_work_order_vendor", "ACME")
      fill_in 'Amount', with: 123.45
      fill_in_selectized("ncr_work_order_approving_official_email", approver.email_address)
      fill_in_selectized("ncr_work_order_org_code", organization.code_and_name)
      click_on "Submit for approval"

      expect(page).to have_content("Proposal submitted")
      expect(page).to have_content(project_title)
      expect(page).to have_content("BA80")
      expect(page).to have_content("ACME")
      expect(page).to have_content("$123.45")
      expect(page).to have_content("Test building")
      expect(page).to have_content(organization.code_and_name)
      expect(page).to have_content("desc content")
    end

    scenario "flash message on error does not persist" do
      login_as(requester)

      visit new_ncr_work_order_path
      fill_in "Project title", with: "test"
      choose "BA60"
      fill_in_selectized("ncr_work_order_vendor", "ACME")
      fill_in 'Amount', with: 123.45
      click_on "Submit for approval"

      expect(page).to have_content("Approving official email can't be blank")
      visit proposals_path
      expect(page).to_not have_content("Approving official email can't be blank")
    end

    scenario "doesn't show the budget fields" do
      login_as(requester)
      visit new_ncr_work_order_path

      focus_field "ncr_work_order_amount"

      expect(page).to have_content("$3,500 for supplies")
      expect(page).to have_content("$2,500 for services")
      expect(page).to have_content("$2,000 for construction")
    end

    scenario "preserve form values on submission error" do
      login_as(requester)
      visit new_ncr_work_order_path

      fill_in "Project title", with: "buying stuff"
      choose "BA80"
      fill_in_selectized("ncr_work_order_vendor", "ACME")
      click_on "Submit for approval"

      expect_page_to_have_selected_selectize_option(
        "ncr_work_order_vendor",
        "ACME"
      )
    end

    scenario "includes previously entered buildings" do
      create(:ncr_work_order, building_number: "BillDing")
      login_as(requester)

      visit new_ncr_work_order_path

      expect_page_to_have_selectized_options("ncr_work_order_building_number", "BillDing")
    end
  end

  def requester
    @_requester ||= create(:user, client_slug: "ncr")
  end

  def focus_field(field_id)
    execute_script "document.getElementById('#{field_id}').scrollIntoView()"
    execute_script "$('##{field_id}').focus()"
  end
end
