describe CommunicartMailerHelper do
  describe '#approve_all_url' do
    let(:approval) { FactoryGirl.build(:approval) }

    it "returns a URL" do
      token = FactoryGirl.build(:api_token)
      expect(approval).to receive(:api_token).and_return(token)

      url = helper.approve_all_url(approval)
      uri = Addressable::URI.parse(url)
      expect(uri.query_values).to eq(
        'approver_action' => 'approve',
        'cart_id' => approval.cart_id.to_s,
        'cch' => token.access_token,
        'user_id' => approval.user_id.to_s
      )
    end

    it "throws an error if there's no token" do
      expect(approval.api_token).to eq(nil)

      expect {
        helper.approve_all_url(approval, true)
      }.to raise_error
    end
  end
end
