feature "Observers" do
  scenario "allows observers to be added" do
    work_order = create(:ncr_work_order)
    observer = create(:user, client_slug: "ncr")
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit proposal_path(proposal)
    select observer.email_address, from: "observation_user_email_address"
    click_on "Add an Observer"

    expect(page).to have_content("#{observer.full_name} has been added as an observer")
  end

  scenario "allows observers to be added by other observers" do
    proposal = create(:proposal, :with_observer)
    observer1 = proposal.observers.first
    observer2 = create(:user, client_slug: nil)
    login_as(observer1)

    visit proposal_path(proposal)
    select observer2.email_address, from: "observation_user_email_address"
    click_on "Add an Observer"

    expect(page).to have_content("#{observer2.full_name} has been added as an observer")
  end

  scenario "allows a user to add a reason when adding an observer" do
    reason = "is the archbishop of banterbury"
    proposal = create(:proposal)
    observer = create(:user, client_slug: nil)
    login_as(proposal.requester)

    visit proposal_path(proposal)
    select observer.email_address, from: "observation_user_email_address"
    fill_in "observation_reason", with: reason
    click_on "Add an Observer"

    expect(page).to have_content("#{observer.full_name} has been added as an observer")
  end

  scenario "hides the reason field until a new observer is selected", :js do
    proposal = create(:proposal)
    observer = create(:user, client_slug: nil)
    login_as(proposal.requester)

    visit proposal_path(proposal)

    expect(page).to have_no_field "observation_reason"

    fill_in_selectized("selectize-control", observer.email_address)

    expect(page).to have_field "observation_reason"
    expect(find_field("observation_reason")).to be_visible
  end

  scenario "disables the submit button until a new observer is selected", :js do
    proposal = create(:proposal)
    observer = create(:user, client_slug: nil)
    login_as(proposal.requester)

    visit proposal_path(proposal)
    submit_button = find("#add_subscriber")

    expect(submit_button).to be_disabled

    fill_in_selectized("selectize-control", observer.email_address)

    expect(submit_button).to_not be_disabled
  end

  scenario "observer can delete themselves as observer" do
    observer = create(:user)
    proposal = create(:proposal, observer: observer)
    login_as(observer)

    visit proposal_path(proposal)
    delete_button = find('table.observers .button_to input[value="Remove"]')
    delete_button.click

    expect(page).to have_content("Removed Observation for ")
  end

  scenario "shows observer roles next to their names" do
    proposal = create(:proposal)
    _procurement = create(:gsa18f_procurement, :with_steps, proposal: proposal)
    purchaser = User.with_role("gsa18f_purchaser").first
    login_as(proposal.requester)

    visit proposal_path(proposal)

    within(".observers") do
      expect(page).to have_content("#{purchaser.email_address} (Purchaser)")
    end
  end
end
