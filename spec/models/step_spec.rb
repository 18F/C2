describe Step do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:proposal) }
  end

  describe "Validations" do
    it { should validate_presence_of(:proposal) }
    it do
      create(:approval) # needed for spec, see https://github.com/thoughtbot/shoulda-matchers/issues/194
      should validate_uniqueness_of(:user_id).scoped_to(:proposal_id)
    end
  end

  let(:approval) { create(:approval) }

  describe '#api_token' do
    let!(:token) { create(:api_token, step: approval) }

    it "returns the token" do
      expect(approval.api_token).to eq(token)
    end

    it "returns nil if the token's been used" do
      token.update_attribute(:used_at, 1.day.ago)
      approval.reload
      expect(approval.api_token).to eq(nil)
    end

    it "returns nil if the token's expired" do
      token.expire!
      approval.reload
      expect(approval.api_token).to eq(nil)
    end
  end

  describe '#approved_at' do
    it 'is nil when pending' do
      expect(approval.approved_at).to be_nil
    end

    it 'is nil when actionable' do
      approval.initialize!
      expect(approval.approved_at).to be_nil
    end

    it 'is set when approved' do
      approval.initialize!
      approval.approve!
      expect(approval.approved_at).not_to be_nil
      approval.reload
      expect(approval.approved_at).not_to be_nil
    end
  end

  describe '#on_approved_entry' do
    it "notified the proposal if the root gets approved" do
      expect(approval.proposal).to receive(:approve!).once
      approval.initialize!
      approval.approve!
    end

    it "does not notify the proposal if a child gets approved" do
      proposal = create(:proposal)
      child1 = build(:approval, user: create(:user))
      child2 = build(:approval, user: create(:user))
      proposal.root_step = build(:serial_steps, child_approvals: [child1, child2])

      expect(proposal).not_to receive(:approve!)
      child1.approve!
    end
  end
end
