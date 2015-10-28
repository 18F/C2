describe CommunicartMailerHelper do
  describe '#generate_approve_url' do
    it "returns a URL" do
      approval = create(:approval)
      token = create(:api_token, approval: approval)
      proposal = approval.proposal

      expect(proposal).to receive(:version).and_return(123)

      url = helper.generate_approve_url(approval)
      uri = Addressable::URI.parse(url)
      expect(uri.path).to eq("/proposals/#{proposal.id}/approve")
      expect(uri.query_values).to eq(
        'cch' => token.access_token,
        'version' => '123'
      )
    end

    it "throws an error if there's no token" do
      approval = build(:approval)
      expect(approval.api_token).to eq(nil)

      expect {
        helper.generate_approve_url(approval)
      }.to raise_error(NoMethodError) # TODO create a more specific error
    end
  end
end
