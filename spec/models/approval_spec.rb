describe Approval do
  let(:approval) { FactoryGirl.create(:approval) }

  describe '#api_token' do
    let!(:token) { approval.create_api_token! }

    it "returns the token" do
      expect(approval.api_token).to eq(token)
    end

    it "returns nil if the token's been used" do
      token.update_attribute(:used_at, 1.day.ago)
      approval.reload
      expect(approval.api_token).to eq(nil)
    end

    it "returns nil if the token's expired" do
      token.update_attribute(:expires_at, 1.day.ago)
      approval.reload
      expect(approval.api_token).to eq(nil)
    end
  end

  describe '#on_approved_entry' do
    it "notified the proposal if the root gets approved" do
      expect(approval.proposal.approved?).to eq false
      approval.make_actionable!
      approval.approve!
      expect(approval.proposal.approved?).to eq true
    end

    it "does not notify the proposal if a child gets approved" do
      proposal = FactoryGirl.create(:proposal)
      proposal.root_approval = Approvals::Parallel.new
      child1 = proposal.add_approver("child1@agency.gov")
      proposal.add_approver("child2@agency.gov")
      proposal.root_approval.make_actionable!

      expect(approval.proposal.approved?).to eq false
      child1.reload.approve!
      expect(approval.proposal.approved?).to eq false
      expect(approval.proposal.pending?).to eq true
    end
  end
end
