module ApprovalSteps

  step 'I go to the approval_response page with token' do
    visit "/approval_response?cart_id=#{@cart.id}&approver_action=approve&cch=#{@token.access_token}"
  end

  step 'I go to the approval_response page without a token' do
    visit "/carts/#{@cart.id}"
  end

  step 'I go to the approval_response page with invalid token :token' do |token|
    visit "/approval_response?cart_id=#{@cart.id}&approver_action=approve&cch=#{token}"
  end

  step "a valid token" do
    @token = ApiToken.create!(user_id: @user.id, cart_id: @cart.id)
  end

  step "the cart has an approval for :email in position :position" do |email, position|
    approver = User.find_or_create_by(email_address: email)
    @cart.proposal.approvals << FactoryGirl.create(:approval, role: 'approver', user_id: approver.id, position: position)
  end

  step "feature flag :flag_name is :value" do |flag, value|
    ENV[flag] = value
  end

  step 'the cart has been approved by the logged in user' do
    approval = @cart.approvals.where(user_id: @current_user.id).first
    approval.update_attributes(status: 'approved')
  end

  step 'the cart has been approved by :email' do |email|
    user = User.find_by(email_address: email)
    approval = @cart.approvals.where(user_id: user.id).first
    approval.update_attributes(status: 'approved')
  end

end
