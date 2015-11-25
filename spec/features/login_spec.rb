feature "Login" do
  scenario "inactive user" do
    inactive_user = create(:user, active: false)

    login_as(inactive_user)

    expect(current_path).to eq feedback_path
    expect(page).to have_content(
      "You are not allowed to login because your account has been inactivated. Please contact an administrator."
    )
  end
end
