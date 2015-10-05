describe "/admin endpoint" do
  let(:user) { FactoryGirl.create(:user) }
  it "requires admin role to access" do
    login_as(user)
    visit '/admin'
    expect(page.status_code).to eq(403)
  end

  it "allows admin role to access" do
    user.add_role('admin')
    login_as(user)
    visit '/admin'
    expect(page.status_code).to eq(200)
    expect(page).to have_content('Dashboard')
  end
end
