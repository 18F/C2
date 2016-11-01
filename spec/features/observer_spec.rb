feature "Observers" do
  scenario "allows observers to be added", :js do
    work_order = create(:ncr_work_order)
    observer = create(:user, client_slug: "ncr")
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit proposal_path(proposal)
    fill_in_selectized("selectize-control", observer.email_address)
    click_on "Add an Observer"

    expect(page).to have_content("#{observer.full_name} is now an observer.")

    # TODO: is already an observer
  end

  scenario "allows observers to be added with javascript in the new detail view", js: true do
    work_order = create(:ncr_work_order, :with_beta_requester)
    observer = create(:user, client_slug: "ncr")
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit proposal_path(proposal)
    within('#card-for-observers') do
      fill_in_selectized("selectize-control", observer.email_address)
    end
    click_on "Add an Observer"
    wait_for_ajax
    within(".observer-list") do
      expect(page).to have_content(observer.full_name.to_s)
    end
  end

  scenario "shows notification when observer is added with javascript in the new detail view", js: true do
    work_order = create(:ncr_work_order, :with_beta_requester)
    observer = create(:user, client_slug: "ncr")
    proposal = work_order.proposal
    login_as(proposal.requester)

    visit proposal_path(proposal)
    within('#card-for-observers') do
      fill_in_selectized("selectize-control", observer.email_address)
    end
    click_on "Add an Observer"
    wait_for_ajax

    expect(page).to have_content("is now an observer.")
  end

  scenario "allows observers to be removed with javascript in the new detail view", js: true do
    work_order = create(:ncr_work_order, :with_beta_requester)
    observer = create(:user, client_slug: "ncr")
    proposal = work_order.proposal
    proposal.add_observer(observer)
    login_as(proposal.requester)

    visit proposal_path(proposal)
    delete_button = find(".observer-remove-button")
    delete_button.click

    within(".observer-modal-content") do
      click_on "REMOVE"
    end

    expect(page).to_not have_content(observer.full_name.to_s)
  end

  scenario "shows notification when observer is deleted with javascript in the new detail view", js: true do
    work_order = create(:ncr_work_order, :with_beta_requester)
    observer = create(:user, :beta_active, client_slug: "ncr")
    proposal = work_order.proposal
    proposal.add_observer(observer)
    login_as(work_order.requester)
    visit proposal_path(proposal)

    delete_button = find(".observer-remove-button")
    delete_button.click

    within(".observer-modal-content") do
      click_on "REMOVE"
    end
    wait_for_ajax

    expect(page).to have_content("removed as an observer")
  end

  scenario "allows observers to remove self with javascript in the new detail view and redirects", js: true do
    work_order = create(:ncr_work_order)
    observer = create(:user, :beta_active, client_slug: "ncr")
    proposal = work_order.proposal
    proposal.add_observer(observer)
    login_as(observer)

    visit proposal_path(proposal)
    delete_button = find(".observer-remove-button")
    delete_button.click

    within(".observer-modal-content") do
      click_on "REMOVE"
    end

    wait_for_ajax
    sleep(1)
    expect(current_path).to eq(proposals_path)
  end

  scenario "allows requester to remove themselves as an observer and not redirect", js: true do
    work_order = create(:ncr_work_order, :with_beta_requester)
    proposal = work_order.proposal
    proposal.add_observer(proposal.requester)
    login_as(proposal.requester)

    visit proposal_path(proposal)
    delete_button = find(".observer-remove-button")
    delete_button.click

    within(".observer-modal-content") do
      click_on "REMOVE"
    end

    wait_for_ajax
    sleep(1)
    expect(current_path).to eq(proposal_path(proposal))
  end

  scenario "allows observers to be added by other observers", :js do
    proposal = create(:ncr_work_order, :with_observers).proposal
    observer1 = proposal.observers.first
    observer2 = create(:user, client_slug: "ncr")
    login_as(observer1)

    visit proposal_path(proposal)
    fill_in_selectized("selectize-control", observer2.email_address)
    click_on "Add an Observer"

    expect(page).to have_content("#{observer2.full_name} is now an observer.")
  end

  scenario "allows a user to add a reason when adding an observer", :js do
    reason = "is the archbishop of banterbury"
    proposal = create(:ncr_work_order).proposal
    observer = create(:user, client_slug: "ncr")
    login_as(proposal.requester)

    visit proposal_path(proposal)
    fill_in_selectized("selectize-control", observer.email_address)
    fill_in "observation_reason", with: reason
    click_on "Add an Observer"

    expect(page).to have_content("#{observer.full_name} is now an observer.")
  end

  scenario "hides the reason field until a new observer is selected", :js do
    proposal = create(:ncr_work_order).proposal
    observer = create(:user, client_slug: "ncr")
    login_as(proposal.requester)

    visit proposal_path(proposal)

    expect(page).to have_no_field "observation_reason"

    fill_in_selectized("selectize-control", observer.email_address)

    expect(page).to have_field "observation_reason"
    expect(find_field("observation_reason")).to be_visible
  end

  scenario "disables the submit button until a new observer is selected", :js do
    proposal = create(:ncr_work_order).proposal
    observer = create(:user, client_slug: "ncr")
    login_as(proposal.requester)

    visit proposal_path(proposal)
    submit_button = find("#add_subscriber")

    expect(submit_button).to be_disabled

    fill_in_selectized("selectize-control", observer.email_address)

    expect(submit_button).to_not be_disabled
  end

  scenario "observer can delete themselves as observer", :js do
    # observer = create(:user)
    proposal = create(:ncr_work_order, :with_observers).proposal
    proposal.observations.last.destroy!
    proposal = Proposal.find(proposal.id)
    observer = proposal.observers.first
    login_as(proposal.observers.first)

    visit proposal_path(proposal)
    delete_button = find('.observer-list .observer-remove-button')
    delete_button.click
    sleep(1)
    click_on "REMOVE"
    sleep(1)
    proposal = Proposal.find(proposal.id)
    expect(proposal.observers.length).to eq(0)
  end

  scenario "shows observer roles next to their names", :js do
    proposal = create(:proposal)
    _procurement = create(:gsa18f_procurement, :with_steps, proposal: proposal)
    purchaser = User.with_role("gsa18f_purchaser").first
    login_as(proposal.requester)

    visit proposal_path(proposal)

    within(".card-for-observers") do
      expect(page).to have_content("#{purchaser.email_address} (Purchaser)")
    end
  end
end
