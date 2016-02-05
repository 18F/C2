feature "Login" do
  scenario "inactive user" do
    inactive_user = create(:user, active: false)

    login_as(inactive_user)

    expect(current_path).to eq feedback_path
    expect(page).to have_content(
      "You are not allowed to login because your account has been deactivated. Please contact an administrator."
    )
  end

  scenario "myusa auth problem" do
    user = create(:user)

    login_as(user)

    # something went wrong. What? No idea.

    visit "/auth/failure?message=invalid_credentials"

    expect(page).to have_content("There was a problem signing you in")
  end
end
