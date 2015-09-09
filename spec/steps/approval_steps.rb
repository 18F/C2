# TODO remove unused steps
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

  step "the proposal has an approval for :email in position :position" do |email, position|
    @approval = Approvals::Individual.new(user: User.for_email(email))
    individuals = @proposal.reload.individual_approvals + [@approval]
    if @proposal.parallel?
      @proposal.root_approval = Approvals::Parallel.new(child_approvals: individuals)
    else
      @proposal.root_approval = Approvals::Serial.new(child_approvals: individuals)
    end
    @approval.set_list_position(position.to_i + 1)   # to account for the root
  end

  step "feature flag :flag_name is :value" do |flag, value|
    ENV[flag] = value
  end

  step 'the proposal has been approved by the logged in user' do
    @proposal.existing_approval_for(@current_user).approve!
  end

  step 'the proposal has been approved by :email' do |email|
    @proposal.existing_approval_for(User.for_email(email)).approve!
  end

end
