feature "Login" do
  scenario "inactive user" do
    inactive_user = create(:user, active: false)

    login_as(inactive_user)

    expect(current_path).to eq feedback_path
    expect(page).to have_content(
      "Your account is no longer active. Please contact an administrator for details."
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
