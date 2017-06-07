feature "Feedback page" do
  scenario "when not logged in" do
    visit feedback_path

    expect(page).to_not have_content(I18n.t("errors.authentication"))
  end

  scenario "as active user" do
    user = create(:user, active: true)

    login_as(user)
    visit feedback_path

    expect(page).not_to have_content(
      "Your account is no longer active. Please contact an administrator for details."
    )
  end

end
