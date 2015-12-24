describe Gsa18f::DashboardController do
  describe "#index" do
    it "does not include proposals user did not participate in" do
      user = create(:user, client_slug: "gsa18f")
      create(:gsa18f_procurement)
      login_as(user)

      get :index

      expect(assigns(:rows)).to be_empty
    end
  end
end
