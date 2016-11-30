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
   
    scenario "does not resave unchanged requests", :js do
      
      work_order_ba80 = create(:ba80_ncr_work_order, :with_beta_requester)
      work_order_ba80.save!
      login_as(work_order_ba80.requester)
      visit proposal_path(work_order_ba80.proposal)
      
      click_on "MODIFY"

      expect(page).to have_css('[data-modal-type="save_confirm"][disabled]')
    end

    scenario "allows requester to change the approving official", :js do
      approver = create(:user, client_slug: "ncr")
      organization = create(:ncr_organization)
      project_title = "buying stuff"
      requester = create(:user, client_slug: "ncr")

      login_as(requester)

      visit new_ncr_work_order_path
      fill_in 'Project title', with: project_title
      fill_in 'Description', with: "desc content"
      choose 'BA80'
      fill_in 'RWA#', with: 'F1234567'
      fill_in_selectized("ncr_work_order_building_number", "Test building")
      fill_in_selectized("ncr_work_order_vendor", "ACME")
      fill_in 'Amount', with: 123.45
      fill_in_selectized("ncr_work_order_approving_official", approver.email_address)
      fill_in_selectized("ncr_work_order_ncr_organization", organization.code_and_name)
      click_on "SUBMIT"

      proposal = requester.proposals.last

      visit proposal_path(proposal)
      
      save_and_open_screenshot

      find(".card-for-observers .selectize-input input").native.send_keys( approver.email_address ) #fill the input text
      first(:xpath, ("//div[@data-selectable and contains(., '#{approver.email_address}')]")).click #wait for the input and then click on it
      
      expect(proposal.approvers.first.email_address).to eq approver.email_address
      expect(proposal.individual_steps.first).to be_actionable
    end

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
