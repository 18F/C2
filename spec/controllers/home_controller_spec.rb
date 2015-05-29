describe HomeController do
  describe '#logout' do
    it "it signs a user out" do
      login_as(FactoryGirl.create(:user))
      expect(session[:user]).not_to be_nil
      get :logout
      expect(response).to redirect_to(root_path)
      expect(session[:user]).to be_nil
    end
  end
end
