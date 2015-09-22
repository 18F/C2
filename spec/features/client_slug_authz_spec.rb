describe "client_slug confers authz rules" do
  it "rejects requests for user with no client_slug" do
    user = FactoryGirl.create(:user)
    login_as(user)
    visit '/ncr/work_orders/new'
    expect(page.status_code).to eq(403)
  end
end
