feature "reports", elasticsearch: true do
  scenario "provides Save as Report button on search results page", js: true do
    user = create(:user, client_slug: "test")
    proposals = populate_proposals(user)
    login_as(user)

    es_execute_with_retries 3 do
      visit query_proposals_path(text: proposals.first.name)
    end
    page.save_screenshot('../screen.png', full: true)
    click_on "Save as Report"
    fill_in "saved-search-name", with: "my test report"
    click_on "Save"

    expect(page).to have_content("Saved as report my test report")
  end

  scenario "provides Save as Report button on search results page with beta", js: true do
    user = create(:user, client_slug: "test")
    user.roles << Role.find_by!(name: ROLE_BETA_USER)
    user.roles << Role.find_by!(name: ROLE_BETA_ACTIVE)

    proposals = populate_proposals(user)
    login_as(user)

    es_execute_with_retries 3 do
      visit query_proposals_path(text: proposals.first.name)
    end

    click_on "Save as Report"
    fill_in "saved-search-name", with: "my test report"
    click_on "Save"

    expect(page).to have_content("Saved as report my test report")
  end

  def populate_proposals(user)
    proposals = 2.times.map do |i|
      wo = create(:test_client_request, project_title: "Work Order #{i}")
      wo.proposal.update(requester: user)
      wo.proposal.reindex
      wo.proposal
    end
    Proposal.__elasticsearch__.refresh_index!
    proposals
  end
end
