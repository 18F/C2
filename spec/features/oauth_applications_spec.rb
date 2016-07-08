describe "OAuth applications" do
  it "allows user to create and authorize application" do
    user = create(:user)
    login_as(user)

    visit "/oauth/applications/new"

    fill_in :doorkeeper_application_name, with: "test"
    fill_in :doorkeeper_application_redirect_uri, with: "urn:ietf:wg:oauth:2.0:oob"
    click_on "Submit"

    expect(page).to have_content("Application created")

    click_on "Authorize"

    expect(page).to have_content("Authorization required")

    click_on "Authorize"

    expect(page).to have_content("Authorization code")
  end
end
