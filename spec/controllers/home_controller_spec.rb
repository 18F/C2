describe HomeController do
  describe "#me" do
    it "can update user profile" do
      user = create(:user)
      login_as(user)
      post :edit_me, first_name: "Some", last_name: "Body"
      expect(response).to redirect_to(:me)
      user.reload
      expect(user.first_name).to eq("Some")
      expect(user.last_name).to eq("Body")
    end
  end
end
      
