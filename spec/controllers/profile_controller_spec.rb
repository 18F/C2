describe ProfileController do
  describe "#show" do
    it "can update user profile" do
      user = create(:user)
      login_as(user)
      post :update, user: { first_name: "Some", last_name: "Body", timezone: "foo/bar" }
      expect(response).to redirect_to(:profile)
      user.reload
      expect(user.first_name).to eq("Some")
      expect(user.last_name).to eq("Body")
      expect(user.timezone).to eq("foo/bar")
    end 
  end 
end
