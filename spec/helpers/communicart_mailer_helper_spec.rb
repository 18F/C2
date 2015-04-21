describe CommunicartMailerHelper do
  describe '#approval_action_url' do
    it "returns a URL" do
      approval = FactoryGirl.create(:approval, :with_cart, :with_user)
      token = approval.create_api_token!

      url = helper.approval_action_url(approval)
      uri = Addressable::URI.parse(url)
      expect(uri.query_values).to eq(
        'approver_action' => 'approve',
        'cart_id' => approval.cart_id.to_s,
        'cch' => token.access_token,
        'version' => approval.proposal.version.to_s
      )
    end

    it "links to the cart if the approver has delegates" do
      approver = FactoryGirl.create(:user, :with_delegate)
      approval = FactoryGirl.create(:approval, :with_cart, user: approver)
      approval.create_api_token!

      url = helper.approval_action_url(approval)
      expect(url).to eq("http://test.host/proposals/#{approval.proposal_id}")
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
