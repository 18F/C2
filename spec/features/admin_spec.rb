describe "admin" do
  it "does not allow Delete of Users" do
    user = create(:user)
    user.add_role("admin")
    login_as(user)

    visit edit_admin_user_path(user)

    expect(page).to_not have_content("Delete User")
  end
end
