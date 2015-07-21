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

  describe '#approved_at' do
    it 'is nil when pending' do
      expect(approval.approved_at).to be_nil
    end

    it 'is nil when actionable' do
      approval.make_actionable!
      expect(approval.approved_at).to be_nil
    end

    it 'is set when approved' do
      approval.make_actionable!
      approval.approve!
      expect(approval.approved_at).not_to be_nil
    end
  end
end
