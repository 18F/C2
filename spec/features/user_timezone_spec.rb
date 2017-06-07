feature "timezone" do
  scenario "user.timezone selected by default in dropdown" do
    user = create(:user, client_slug: "test")
    login_as(user)

    profile_page = ProfilePage.new
    profile_page.load

    expect(profile_page).to be_displayed
    expect(profile_page.timezone.value).to eq(user.timezone)
  end

  scenario "empty user.timezone defaults to browser-timezone cookie", :js do
    user = create(:user, client_slug: "ncr", timezone: nil)
    proposal = create(:ncr_work_order, requester: user).proposal
    login_as(user)

    expect(user.timezone).to be_nil

    proposal_page = ProposalPage.new
    proposal_page.load(proposal_id: proposal.id)

    expect(proposal_page).to be_displayed

    Time.use_zone browser_cookie_timezone do
      created_at_time = proposal_submitted_at(proposal)
      expect(proposal_page.description_redesign.submitted_redesign.text).to eq(created_at_time)
    end
  end

  scenario "user.timezone used if set", :js do
    user = create(:user, client_slug: "ncr", timezone: User::DEFAULT_TIMEZONE)
    proposal = create(:ncr_work_order, requester: user).proposal
    login_as(user)
    @client_data_instance ||= proposal.client_data
    proposal_page = ProposalPage.new
    proposal_page.load(proposal_id: proposal.id)
    expect(proposal_page).to be_displayed
    Time.use_zone user.timezone do
      created_at_time = proposal_submitted_at(proposal)
      expect(proposal_page.description_redesign.submitted_redesign.text).to eq(created_at_time)
    end
  end

  def browser_cookie_timezone
    Capybara.current_session.driver.browser.cookies["browser.timezone"].value.gsub("%2F", "/")
  end

  def proposal_submitted_at(proposal)
    proposal.created_at.in_time_zone.strftime("%b %-d, %Y at %l:%M%P").sub("  ", " ")
  end
end
