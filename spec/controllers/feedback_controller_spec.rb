describe FeedbackController do
  describe '#create' do
    it 'sends an email when feedback is submitted' do
      post :create, {
        bug: 'Yes',
        context: 'Some context here',
        expected: 'it to work', 
        actually: 'it did not',
        comments: 'Comments here',
        satisfaction: '4',
        referral: '/somewhere/else'
      }
      expect(deliveries.count).to be(1)
      expect(deliveries[0].body.to_s).to eq(
        ["bug: Yes", "context: Some context here", "expected: it to work",
         "actually: it did not", "comments: Comments here", "satisfaction: 4",
         "referral: /somewhere/else"].join("\n"))
      expect(deliveries[0].cc).to eq([])
    end

    it "doesn't include extra fields" do
      post :create, {bug: 'Yes', bogus: 'Field'}
      expect(deliveries[0].body.to_s).to eq("bug: Yes")
    end

    it "doesn't include blank fields" do
      post :create, {comments: "    ", actually: 'ACT'}
      expect(deliveries[0].body.to_s).to eq("actually: ACT")
    end

    it "includes user if signed in" do
      user = FactoryGirl.create(:user, email_address: "actor@example.com")
      login_as(user)
      post :create, {bug: "Yes"}
      expect(deliveries[0].body.to_s).to eq("bug: Yes")
      expect(deliveries[0].cc).to eq(["actor@example.com"])
    end
  end
end
