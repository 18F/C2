describe SummaryController do
  describe "#index" do
    it "requires client_admin or admin role, with client_slug" do
      user = create(:user)
      login_as(user)
      get :index
      expect(response.status).to eq(403)
    end

    it "requires client_slug" do
      admin_user = create(:user, :admin)
      login_as(admin_user)
      get :index
      expect(response.status).to eq(403)
    end

    it "requires admin or client_admin role" do
      admin_user = create(:user, :admin, client_slug: "ncr")
      login_as(admin_user)
      get :index
      expect(response.status).to eq(200)

      client_admin_user = create(:user, :client_admin, client_slug: "ncr")
      login_as(client_admin_user)
      get :index
      expect(response.status).to eq(200)
    end

    it "takes optional fiscal year" do
      admin_user = create(:user, :admin, client_slug: "ncr")
      login_as(admin_user)
      get :index, fiscal_year: 2015
      expect(response.status).to eq(200)
    end
  end
end
