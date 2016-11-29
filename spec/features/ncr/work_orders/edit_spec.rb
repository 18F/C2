feature "Editing NCR work order" do
  include ProposalSpecHelper

  scenario "current user is not the requester, approver, or observer", :js do
    work_order = create(:ncr_work_order)
    stranger = create(:user, client_slug: "ncr")
    login_as(stranger)

    visit proposal_path(work_order.proposal)
    expect(current_path).to eq(proposal_path(work_order.proposal))
    expect(page).to have_content(I18n.t("errors.policies.proposal.show_permission"))
  end

  context "work_order has pending status" do
    
    scenario "preserves previously selected values in dropdowns", :js do
      work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
      work_order_ba80.save!
      login_as(work_order_ba80.requester)
      visit proposal_path(work_order_ba80.proposal)
      
      click_on "MODIFY"

      within(".ncr_work_order_building_number") do
        find(".selectize-control").click
        within(".dropdown-active") do
          expect(page).to have_content(Ncr::BUILDING_NUMBERS[0])
        end
        find(".selectize-control").click
      end
    end

    scenario "notifies observers of changes", :js do
      orig_value = ActionMailer::Base.perform_deliveries
      ActionMailer::Base.perform_deliveries = true

      deliveries = ActionMailer::Base.deliveries

      work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
      work_order_ba80.save!
      
      user = create(:user, client_slug: "ncr", email_address: "observer@example.com")
      work_order_ba80.add_observer(user)
      login_as(work_order_ba80.requester)
      visit proposal_path(work_order_ba80.proposal)

      click_on "MODIFY"

      fill_in 'ncr_work_order[project_title]', with: "Really new project title"

      within(".action-bar-container") do
        click_on "SAVE"
        sleep(1)
      end
      within("#card-for-modal") do
        click_on "SAVE"
        sleep(1)
      end
      
      sleep(1)

      expect(deliveries.length).to eq(2)
      expect(deliveries.last).to have_content(user.full_name)

      ActionMailer::Base.deliveries.clear
      ActionMailer::Base.perform_deliveries = orig_value
    end

    scenario "BA80 can be modified", :js do
      work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
      work_order_ba80.save!
      login_as(work_order_ba80.requester)
      visit proposal_path(work_order_ba80.proposal)

      click_on "MODIFY"

      fill_in 'ncr_work_order[project_title]', with: "New project title"
      fill_in 'ncr_work_order[description]', with: "New desc content"
      fill_in 'ncr_work_order[rwa_number]', with: 'F0000000'
      fill_in 'ncr_work_order[amount]', with: 3.45
      select "Not to exceed", from: "ncr_work_order_not_to_exceed"

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
      expect(page).to have_content("F0000000")
      expect(page).to have_content("New desc content")
      expect(page).to have_content("Not to exceed")
      expect(page).to have_content("3.45")
    end
  end
end
