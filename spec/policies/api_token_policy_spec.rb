describe ApiTokenPolicy do
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

  def approval_params_with_token
    @approval_params_with_token ||= {
      cch: token.access_token,
      id: proposal.id.to_s,
      approver_action: "approve"
    }.with_indifferent_access
  end

  def token
    @token ||= create(:api_token, step: approval)
  end

  def proposal
    @proposal ||= create(:proposal, :with_approver)
  end

  def approval
    @approval ||= proposal.individual_steps.first
  end

  def approver
    @approver ||= approval.user
  end
end
