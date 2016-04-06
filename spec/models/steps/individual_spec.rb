describe Steps::Individual do
  describe "#delegates" do
    it "returns a list of users" do
      approval = create(:approval)
      approver = approval.user
      delegate = create(:user)
      approver.add_delegate(delegate)

      expect(approval.delegates).to eq([delegate])
    end
  end

  describe "#completed_by" do
    it "identifies completed_by" do
      approval = create(:approval)
      delegate = create(:user)
      approval.completer = delegate
      approval.save!
      approval_self = create(:approval)

      expect(approval.completed_by).to eq delegate
      expect(approval_self.completed_by).to eq approval_self.user
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

    it "resets completed_by and completed_at" do
      completer_user = create(:user)
      assigned_user = create(:user)
      step = create(:approval_step, user: assigned_user)
      step.initialize!
      step.update_attributes!(completer: completer_user, completed_at: Time.current)
      step.complete!

      expect(step.completed_by).to eq(completer_user)
      expect(step.completed?).to eq(true)

      step.restart!
      step.reload

      expect(step.pending?).to eq(true)
      expect(step.completer).to be_nil
      expect(step.completed_at).to be_nil
      expect(step.completed_by).to eq(assigned_user)
    end
  end
end
