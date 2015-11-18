describe "admin" do
  it "requires admin role to access" do
    login_as(user)

    get "/admin"

    expect(response.status).to eq(403)
  end

  it "redirects if not logged in" do
    get "/admin"

    expect(response.status).to eq(302)
  end

  it "user is an admin" do
    user.add_role("admin")
    login_as(user)

    get "/admin"

    expect(response.status).to eq(200)
  end

  def user
    @user ||= create(:user)
  end
end
