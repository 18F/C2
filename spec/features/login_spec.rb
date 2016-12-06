feature "Login" do
  include EnvVarSpecHelper
  scenario "inactive user" do
    inactive_user = create(:user, active: false)

    login_as(inactive_user)

    expect(current_path).to eq feedback_path
    expect(page).to have_content(
      "Your account is no longer active. Please contact an administrator for details."
    )
  end

  scenario "cloud.gov auth problem" do
    user = create(:user)

    login_as(user)

    # something went wrong. What? No idea.

    visit "/auth/failure?message=invalid_credentials"

    expect(page).to have_content("There was a problem signing you in")
  end

  scenario "user logs in without env REDESIGN_DEFAULT_VIEW without being beta user" do
    with_env_var('REDESIGN_DEFAULT_VIEW', nil) do
      user = create(:user)
      login_as(user)
      expect(user.in_beta_program?).to eq(false)
      expect(user.active_beta_user?).to eq(false)
    end
  end

  scenario "user logs in with env REDESIGN_DEFAULT_VIEW becomes beta user" do
    with_env_var('REDESIGN_DEFAULT_VIEW', 'true') do
      user = create(:user)
      login_as(user)
      expect(user.in_beta_program?).to eq(true)
      expect(user.active_beta_user?).to eq(true)
    end
  end

end
