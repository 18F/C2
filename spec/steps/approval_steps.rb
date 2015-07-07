module ApprovalSteps

  step 'I go to the approval_response page with token' do
    visit "/proposals/#{@cart.proposal_id}/approve?cch=#{@token.access_token}"
  end

  step 'I go to the approval_response page without a token' do
    visit "/proposals/#{@cart.proposal.id}"
  end

  step 'I go to the approval_response page with invalid token :token' do |token|
    visit "/proposals/#{@cart.proposal_id}/approve?cch=#{token}"
  end

  step "a valid token" do
    @token = ApiToken.create!(approval_id: @approval.id)
  end

  step "the cart has an approval for :email in position :position" do |email, position|
    # @todo: this is ugly. replace once we remove the associated acceptance tests
    root = @cart.proposal.root_approval
    if root.nil? && @cart.proposal.linear?
      @cart.proposal.root_approval = Approvals::Serial.new(status: :actionable)
    elsif root.nil?
      @cart.proposal.root_approval = Approvals::Parallel.new(status: :actionable)
    end

    @approval = @cart.proposal.add_approver(email)
    if @cart.proposal.parallel? || @cart.proposal.approvals.count == 2
      @approval.update(position: position, status: :actionable)
    else
      @approval.update(position: position)
    end
  end

  step "feature flag :flag_name is :value" do |flag, value|
    ENV[flag] = value
  end

  step 'the cart has been approved by the logged in user' do
    approval = @cart.approvals.where(user_id: @current_user.id).first
    approval.approve!
  end

  step 'the cart has been approved by :email' do |email|
    user = User.find_by(email_address: email)
    approval = @cart.approvals.where(user_id: user.id).first
    approval.approve!
  end

end
