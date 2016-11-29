describe AuthController do
  describe '#logout' do
    it "it signs a user out" do
      login_as(create(:user))
      expect(session[:user]).not_to be_nil
      get :logout
      expect(response).to redirect_to(root_path)
      expect(session[:user]).to be_nil
    end
  end

  describe "#oauth_callback" do
    include IntegrationSpecHelper
    it "recovers gracefully from missing email address" do
      user = build(:user, email_address: "")
      setup_mock_auth(:cg, user)
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:cg]
      get :oauth_callback, provider: :cg
      expect(session[:user]).to be_nil
      expect(response.status).to eq(200)
    end
  end
end
