feature "Create a Gsa18F procurement" do
  scenario "user not signed in" do
    visit new_gsa18f_procurement_path

    expect(page).to have_content("You need to sign in")
  end

  context "user signed in" do
    scenario "saves a Proposal with the attributes" do
      login_as(requester)
      visit new_gsa18f_procurement_path

      fill_in "Product name and description", with: "buying stuff"
      select "Software", from: "gsa18f_procurement_purchase_type"
      fill_in "Justification", with: "because I need it"
      fill_in "Link to product", with: "http://www.amazon.com"
      fill_in "Cost per unit", with: 123.45
      fill_in "Quantity", with: 6
      fill_in "gsa18f_procurement_date_requested", with: "12/12/2999"
      fill_in "gsa18f_procurement_additional_info", with: "none"
      select Gsa18f::Procurement::URGENCY[10], from: "gsa18f_procurement_urgency"
      select Gsa18f::Procurement::OFFICES[0], from: "gsa18f_procurement_office"
      click_on "Submit for approval"

      proposal = requester.reload.proposals.last
      expect(page).to have_content("Proposal submitted")
      expect(current_path).to eq(proposal_path(proposal))
    end

    context "invalid input" do
      scenario "shows error and preserve form inputs" do
        login_as(requester)
        visit new_gsa18f_procurement_path

        fill_in "Product name and description", with: "buying stuff"
        fill_in "Quantity", with: 1
        fill_in "Cost per unit", with: 10_000
        click_on "Submit for approval"

        expect(current_path).to eq(gsa18f_procurements_path)
        expect(page).to have_content("Cost per unit must be less than or equal to $")
        expect(find_field("Cost per unit").value).to eq("10000")
      end
    end
  end

  def requester
    @_requester ||= create(:user, client_slug: "gsa18f")
  end
end
