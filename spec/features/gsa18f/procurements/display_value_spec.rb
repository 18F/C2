feature "the values displayed on procurements" do
  scenario "requester can see procurement details" do
    requester = create(:user, :beta_active, client_slug: "gsa18f" )
    supervisor = create(:user, client_slug: "gsa18f", email_address: "supervisor@gsa.gov", first_name: "super")
    login_as(requester)

    visit new_gsa18f_procurement_path

    select "Software", from: "gsa18f_procurement[purchase_type]"
    fill_in "gsa18f_procurement[product_name_and_description]", with: "Test title"
    fill_in "gsa18f_procurement[justification]", with: "Test Justification"
    fill_in "gsa18f_procurement[link_to_product]", with: "Test provider"
    fill_in "gsa18f_procurement[cost_per_unit]", with:"200"
    fill_in "gsa18f_procurement[quantity]", with:"33"
    find(:css, "#gsa18f_procurement_is_tock_billable").set(true)
    find(:css, "#gsa18f_procurement_recurring").set(true)
    select "Monthly", from: "gsa18f_procurement[recurring_interval]"
    fill_in "gsa18f_procurement[recurring_length]", with:"19"
    fill_in "gsa18f_procurement[date_requested]", with: "11/12/2999"
    select 30, from: "gsa18f_procurement[urgency]"

    click_on "SUBMIT"

    proposal = requester.reload.proposals.last
    expect(page).to have_content("Software")
    expect(page).to have_content("Product name and description")
    expect(page).to have_content("Justification")
    expect(page).to have_content("Event provider")
    expect(page).to have_content("200")
    expect(page).to have_content("33")
    expect(page).to have_content("This project is billable")
    expect(page).to have_content("This is recurring")
    expect(page).to have_content("Monthly")
    expect(page).to have_content("19")

    expect(current_path).to eq(proposal_path(proposal))
  end
end
