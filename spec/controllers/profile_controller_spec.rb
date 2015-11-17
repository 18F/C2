describe ProfileController do
  describe "#show" do
    it "can update user profile" do
      user = create(:user)
      login_as(user)
      post :update, first_name: "Some", last_name: "Body"
      expect(response).to redirect_to(:profile)
      user.reload
      expect(user.first_name).to eq("Some")
      expect(user.last_name).to eq("Body")
    end 
  end 
end
