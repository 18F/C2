feature "Create a Gsa18F event" do
  include EventSpecHelper

  scenario "user not signed in" do
    visit new_gsa18f_event_path

    expect(page).to have_content("You need to sign in")
  end

  context "user signed in" do
    scenario "saves an event with the attributes", :js do
      requester = create(:user, :beta_active, client_slug: "gsa18f" )
      supervisor = create(:user, client_slug: "gsa18f", email_address: "supervisor@gsa.gov", first_name: "super")
      login_as(requester)

      visit new_gsa18f_event_path

      fill_in "gsa18f_event_duty_station", with: "DC"
      select "supervisor@gsa.gov", from: "Supervisor"
      fill_in "Event title", with: "Test title"
      fill_in "Event provider", with: "Test provider"
      find("#gsa18f_event_type_of_event_conference").trigger("click")
      fill_in "Cost of event (not including travel)", with:"200"
      fill_in "Training start date", with: "12/12/2999"
      fill_in "Training end date", with: "11/12/2999"
      fill_in "Purpose of event", with: "Test purpose"
      fill_in "Justification", with: "because I need it"
      fill_in "Link to purchase event", with: "www.gsa.gov"
      fill_in "Instructions to purchase event", with: "go buy it"
      execute_script("$('[name=\"attachments[]\"][required=\"required\"]').css('display', 'block')")
      page.attach_file("attachments[]", "#{Rails.root}/app/assets/images/attachment.png")

      click_on "SUBMIT"

      proposal = requester.reload.proposals.last
      expect(page).to have_content("Proposal submitted")
      expect(page).to have_content("DC")
      expect(page).to have_content("super")
      expect(page).to have_content("Test title")
      expect(page).to have_content("Test provider")
      expect(page).to have_content("Dec 12, 2999")
      expect(page).to have_content("Dec 11, 2999")
      expect(page).to have_content("Test purpose")
      expect(page).to have_content("because I need it")
      expect(page).to have_content("www.gsa.gov")
      expect(page).to have_content("go buy it")
      expect(current_path).to eq(proposal_path(proposal))
    end
  end
end
