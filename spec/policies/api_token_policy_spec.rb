describe ApiTokenPolicy do
  let(:token) { create(:api_token, step: approval) }
  let(:approval) { proposal.individual_steps.first }
  let(:proposal) { create(:proposal, :with_approver) }
  let(:approver) { approval.user }
  let(:approval_params_with_token) do
    {
      cch: token.access_token,
      id: proposal.id.to_s,
      approver_action: "approve"
    }.with_indifferent_access
  end

  permissions :valid? do
    it "allows valid parameters" do
      expect(ApiTokenPolicy).to permit(approval_params_with_token, :api_token)
    end

    it "fails when the token does not exist" do
      approval_params_with_token[:cch] = nil

      expect(ApiTokenPolicy).not_to permit(approval_params_with_token, :api_token)
    end

    it "fails when the token does not match an existing token" do
      approval_params_with_token[:cch] = "abcdefg"

      expect(ApiTokenPolicy).not_to permit(approval_params_with_token, :api_token)
    end

    it "fails when the token has expired" do
      token.expire!
      expect(ApiTokenPolicy).not_to permit(approval_params_with_token, :api_token)
    end

    it "fails when the token has already been used once" do
      token.update(used_at: 1.hour.ago)

      expect(ApiTokenPolicy).not_to permit(approval_params_with_token, :api_token)
    end
  end

  permissions :valid_and_not_delegate? do
    it "allows non-delegates to use" do
      expect(ApiTokenPolicy).to permit(approval_params_with_token, :api_token)
    end

    it "does not allow delegates to use" do
      token.user.add_delegate(create(:user))

      expect(ApiTokenPolicy).not_to permit(approval_params_with_token, :api_token)
    end
  end
end
