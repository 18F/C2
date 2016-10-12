feature "Editing NCR work order" do
  scenario "current user is not the requester, approver, or observer" do
    work_order = create(:ncr_work_order)
    stranger = create(:user, client_slug: "ncr")
    login_as(stranger)

    visit "/ncr/work_orders/#{work_order.id}/edit"
    expect(current_path).to eq("/ncr/work_orders/new")
    expect(page).to have_content(I18n.t("errors.policies.ncr.work_order.can_edit"))
  end

  context "work_order has pending status" do
    scenario "BA80 can be modified", :js do
      approver = create(:user, client_slug: "ncr")
      organization = create(:ncr_organization)
      project_title = "buying stuff"
      requester = create(:user, client_slug: "ncr")

      login_as(requester)

      visit new_ncr_work_order_path
      fill_in 'Project title', with: "Project title"
      fill_in 'Description', with: "desc content"
      choose 'BA80'
      fill_in 'RWA Number', with: 'F1234567'
      fill_in_selectized("ncr_work_order_building_number", "Test building")
      fill_in_selectized("ncr_work_order_vendor", "ACME")
      fill_in 'Amount', with: 123.45
      fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
      fill_in_selectized("ncr_work_order_ncr_organization", organization.code_and_name)
      click_on "Submit for approval"

      click_on "MODIFY"

      fill_in 'Project title', with: "New project title"
      fill_in 'Description', with: "New desc content"
      choose 'BA80'
      fill_in 'RWA Number', with: 'F0000000'
      fill_in_selectized("ncr_work_order_building_number", "New Test building")
      fill_in_selectized("ncr_work_order_vendor", "New ACME")
      fill_in 'Amount', with: 3.45
      fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
      fill_in_selectized("ncr_work_order_ncr_organization", organization.code_and_name)
      click_on "Submit for approval"

      within(".action-bar-container") do
          click_on "SAVE"
          sleep(1)
        end
        within("#card-for-modal") do
          click_on "SAVE"
          sleep(1)
        end

      expect(page).to have_content("New project title")
      expect(page).to have_content("BA80")
      expect(page).to have_content("New ACME")
      expect(page).to have_content("F0000000")
      expect(page).to have_content("New desc content")
      expect(page).to have_content("$3.45")
      expect(page).to have_content("New Test building")
      expect(page).to have_content(organization.code_and_name)
    end
  end
end
