describe "User can manage their own profile" do
  it "allows editing of name" do
    user = create(:user)
    login_as(user)
    visit "/profile"
    fill_in "user[first_name]", with: "Some"
    fill_in "user[last_name]", with: "Body"
    click_button "Update profile"
    expect(page).to have_content("Welcome, Some Body <#{user.email_address}>")
  end
end
