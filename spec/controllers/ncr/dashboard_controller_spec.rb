describe Ncr::DashboardController do
  describe "#index" do
    it "does not include proposals user did not participate in" do
      user = create(:user)
      login_as(user)
      create(:ncr_work_order)

      get :index

      expect(assigns(:rows)).to be_empty
    end
  end
end
