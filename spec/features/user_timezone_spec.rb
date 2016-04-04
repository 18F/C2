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
    user = create(:user, client_slug: "test", timezone: nil)
    proposal = create(:proposal, client_slug: "test", requester: user)
    login_as(user)

    expect(user.timezone).to be_nil

    proposal_page = ProposalPage.new
    proposal_page.load(proposal_id: proposal.id)

    expect(proposal_page).to be_displayed

    Time.use_zone browser_cookie_timezone do
      created_at_time = proposal_submitted_at(proposal)
      expect(proposal_page.description.submitted[:title]).to eq(created_at_time)
    end
  end

  scenario "user.timezone used if set" do
    user = create(:user, client_slug: "test", timezone: "EST")
    proposal = create(:proposal, client_slug: "test", requester: user)
    login_as(user)

    proposal_page = ProposalPage.new
    proposal_page.load(proposal_id: proposal.id)
    expect(proposal_page).to be_displayed
    Time.use_zone user.timezone do
      created_at_time = proposal_submitted_at(proposal)
      expect(proposal_page.description.submitted[:title]).to eq(created_at_time)
    end
  end

  def browser_cookie_timezone
    Capybara.current_session.driver.browser.cookies["browser.timezone"].value.gsub("%2F", "/")
  end

  def proposal_submitted_at(proposal)
    proposal.created_at.in_time_zone.strftime("%b %-d, %Y at %l:%M%P")
  end
end
