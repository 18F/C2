describe Approvals::Individual do
  let(:approval) { create(:approval) }

  describe '#delegates' do
    it "returns a list of users" do
      approver = approval.user
      delegate = create(:user)
      approver.add_delegate(delegate)

      expect(approval.delegates).to eq([delegate])
    end
  end
end
