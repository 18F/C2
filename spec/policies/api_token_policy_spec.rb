describe ApiTokenPolicy do
  subject { described_class }
  let(:cart) { FactoryGirl.create(:cart_with_approvals) }
  let(:approval) { cart.proposal.user_approvals.first }
  let(:approver) { approval.user }
  let(:token) { approval.create_api_token! }
  let(:proposal) { cart.proposal }
  let(:approval_params_with_token) {
    {
      cch: token.access_token,
      cart_id: cart.id.to_s,
      approver_action: 'approve'
    }.with_indifferent_access
  }

  permissions :valid? do
    it "allows valid parameters" do
      expect(subject).to permit(approval_params_with_token, :api_token)
    end

    it "fails when the token does not exist" do
      approval_params_with_token[:cch] = nil
      expect(subject).not_to permit(approval_params_with_token, :api_token)
    end

    it "fails when the token does not match an existing token" do
      approval_params_with_token[:cch] = "abcdefg"
      expect(subject).not_to permit(approval_params_with_token, :api_token)
    end

    it "fails when the token has expired" do
      token.update_attributes(expires_at: 8.days.ago)
      expect(subject).not_to permit(approval_params_with_token, :api_token)
    end

    it 'fails when the token has already been used once' do
      token.update_attributes(used_at: 1.hour.ago)
      expect(subject).not_to permit(approval_params_with_token, :api_token)
    end
  end

  permissions :not_delegate? do
    it "allows non-delegates to use" do
      expect(subject).to permit(approval_params_with_token, :api_token)
    end

    it "does not allow delegates to use" do
      token.user.add_delegate(FactoryGirl.create(:user))
      expect(subject).not_to permit(approval_params_with_token, :api_token)
    end
  end
end
