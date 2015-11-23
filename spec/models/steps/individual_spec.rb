describe Steps::Individual do
  describe '#delegates' do
    it "returns a list of users" do
      approval = create(:approval)
      approver = approval.user
      delegate = create(:user)
      approver.add_delegate(delegate)

      expect(approval.delegates).to eq([delegate])
    end

    it "identifies the completer" do
      approval = create(:approval)
      approver = approval.user
      delegate = create(:user)
      approval.completed_by = delegate
      approval.save!
      approval_self = create(:approval)

      expect(approval.completer).to eq delegate
      expect(approval_self.completer).to eq approval_self.user
    end
  end

  describe '#restart!' do
    it "expires the API token" do
      approval = create(:approval, status: 'actionable')
      token = approval.create_api_token!
      expect(token.expired?).to eq(false)
      approval.restart!
      expect(token.expired?).to eq(true)
    end

    it "handles a missing API token" do
      approval = create(:approval, status: 'actionable')
      expect {
        approval.restart!
      }.to_not raise_error
    end
  end
end
