describe CommunicartMailerHelper do
  describe '#approval_action_url' do
    it "returns a URL" do
      approval = FactoryGirl.create(:approval, :with_proposal, :with_user)
      token = approval.create_api_token!
      proposal = approval.proposal

      expect(proposal).to receive(:version).and_return(123)

      url = helper.approval_action_url(approval)
      uri = Addressable::URI.parse(url)
      expect(uri.path).to eq("/proposals/#{proposal.id}/approve")
      expect(uri.query_values).to eq(
        'cch' => token.access_token,
        'version' => '123'
      )
    end

    it "leaves out the token if the approver has delegates" do
      approver = FactoryGirl.create(:user, :with_delegate)
      approval = FactoryGirl.create(:approval, :with_proposal, user: approver)
      approval.create_api_token!
      proposal = approval.proposal

      expect(proposal).to receive(:version).and_return(123)

      url = helper.approval_action_url(approval)
      uri = Addressable::URI.parse(url)
      expect(uri.path).to eq("/proposals/#{proposal.id}/approve")
      expect(uri.query_values).to eq(
        'version' => '123'
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
