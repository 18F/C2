describe CommunicartMailerHelper do
  describe '#approval_action_url' do
    it "returns a URL" do
      approval = FactoryGirl.build(:approval, :with_cart)
      token = FactoryGirl.build(:api_token)
      expect(approval).to receive(:api_token).and_return(token)

      url = helper.approval_action_url(approval)
      uri = Addressable::URI.parse(url)
      expect(uri.query_values).to eq(
        'approver_action' => 'approve',
        'cart_id' => approval.cart_id.to_s,
        'cch' => token.access_token,
        'user_id' => approval.user_id.to_s
      )
    end

    it "throws an error if there's no token" do
      approval = FactoryGirl.build(:approval)
      expect(approval.api_token).to eq(nil)

      expect {
        helper.approval_action_url(approval)
      }.to raise_error
    end
  end
end
