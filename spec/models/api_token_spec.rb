describe ApiToken do
  describe '.create' do
    it "sets the access_token" do
      token = ApiToken.create!(approval_id: 1)
      expect(token.access_token).to_not be_blank
    end

    it "doesn't duplicate an existing access_token" do
      existing_token = FactoryGirl.create(:api_token)
      expect(SecureRandom).to receive(:hex).and_return(existing_token.access_token, 'newtoken')

      token = ApiToken.create!(approval_id: 1)
      expect(token.access_token).to eq('newtoken')
    end

    it "sets the expiry" do
      Timecop.freeze do
        token = ApiToken.create!(approval_id: 1)
        expect(token.expires_at).to eq(7.days.from_now)
      end
    end
  end
end
