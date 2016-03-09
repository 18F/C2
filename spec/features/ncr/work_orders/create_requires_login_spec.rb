feature "Creating an NCR work order requires user to log in" do
  include EnvVarSpecHelper

  scenario "requires sign-in" do
    visit new_ncr_work_order_path

    expect(current_path).to eq root_path
    expect(page).to have_content("You need to sign in")
  end

  scenario "requires a GSA email address" do
    with_env_var("RESTRICT_ACCESS", "true") do
      user = create(:user, email_address: "intruder@example.com", client_slug: "ncr")
      login_as(user)

      visit new_ncr_work_order_path

      expect(page).to have_content("You must be logged in with a GSA email address")
    end
  end
end
