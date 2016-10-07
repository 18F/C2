feature "Edit a Gsa18F procurement" do
  include EventSpecHelper
  context "User is requester" do
    context "event has pending status" do
      scenario "can be modified", :js do
        proposal = create_event
        requester = proposal.requester
        login_as(requester)
        visit proposal_path(proposal)

        click_on "MODIFY"
        fill_in "gsa18f_event_title_of_event", with: "event title edited"
        fill_in "Duty station", with: "duty station edited"
        fill_in "Event provider", with: "Event provider edited"
        fill_in "gsa18f_event_cost_per_unit", with: "1.11"
        fill_in "gsa18f_event_start_date", with: "01/01/2020"
        fill_in "gsa18f_event_end_date", with: "01/01/2021"
        fill_in "Purpose", with: "purpose edit"
        fill_in "Justification", with: "Justification edit"
        fill_in "Instructions", with: "Instructions edit"
        select requester.full_name, from: "Supervisor"
        within(".action-bar-container") do
          click_on "SAVE"
          sleep(1)
        end
        within("#card-for-modal") do
          click_on "SAVE"
          sleep(1)
        end
        page.save_screenshot('../screen.png', full: true)
        expect(page).to have_content("event title edited")
        expect(page).to have_content("Event provider edited")
        expect(page).to have_content("1.11")
        expect(page).to have_content("2021-01-01")
        expect(page).to have_content("2020-01-01")
        expect(page).to have_content("purpose edit")
        expect(page).to have_content("Justification edit")
        expect(page).to have_content("Instructions edit")
        expect(page).to have_content(requester.full_name)

        proposal = Proposal.find(proposal.id)
        expect(proposal.client_data.title_of_event).to eq("event title edited")

      end
    end
  end
end
