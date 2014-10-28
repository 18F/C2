module ApprovalSteps

  step 'I go to the approval_response page with token' do
    visit "/approval_response?cart_id=#{@cart.id}&user_id=#{@user.id}&approver_action=approve&cch=#{@token.access_token}"
  end

  step 'I go to the approval_response page with invalid token :token' do |token|
    visit "/approval_response?cart_id=#{@cart.id}&user_id=#{@user.id}&approver_action=approve&cch=#{token}"
  end

  step "a valid token" do
    @token = ApiToken.create(user_id: @user.id, cart_id: @cart.id)
  end

  step "the user is associated with one of the cart's approvals" do
    @cart.approvals.last.update_attributes(user_id: @user.id)
  end

  step "feature flag :flag_name is :value" do |flag, value|
    ENV[flag] = value
  end

end
