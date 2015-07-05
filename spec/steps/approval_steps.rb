module ApprovalSteps

  step 'I go to the approval_response page with token' do
    visit "/proposals/#{@proposal.id}/approve?cch=#{@token.access_token}"
  end

  step 'I go to the approval_response page without a token' do
    visit "/proposals/#{@proposal.id}"
  end

  step 'I go to the approval_response page with invalid token :token' do |token|
    visit "/proposals/#{@proposal.id}/approve?cch=#{token}"
  end

  step "a valid token" do
    @token = ApiToken.create!(approval_id: @approval.id)
  end

  step "the cart has an approval for :email in position :position" do |email, position|
    @approval = @proposal.add_approver(email)
    @approval.update_attribute(:position, position)
    @proposal.initialize_approvals()
  end

  step "feature flag :flag_name is :value" do |flag, value|
    ENV[flag] = value
  end

  step 'the cart has been approved by the logged in user' do
    approval = @proposal.approvals.where(user_id: @current_user.id).first
    approval.approve!
  end

  step 'the cart has been approved by :email' do |email|
    user = User.find_by(email_address: email)
    approval = @proposal.approvals.where(user_id: user.id).first
    approval.approve!
  end

end
