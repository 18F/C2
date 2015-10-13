describe 'Linear approvals' do
  it 'allows the approver to approve' do
    proposal = create_proposal
    first_approver = FactoryGirl.create(:user)
    second_approver = FactoryGirl.create(:user)
    approvals = create_approvals_for([first_approver, second_approver])
    create_serial_approval(approvals)

    login_as(first_approver)
    visit proposal_path(proposal)

    expect(page).to have_button('Approve')
  end

  it 'does not allow the approver to approve twice' do
    proposal = create_proposal
    first_approver = FactoryGirl.create(:user)
    second_approver = FactoryGirl.create(:user)
    approvals = create_approvals_for([first_approver, second_approver])
    create_serial_approval(approvals)
    approve_approval_for(first_approver)

    login_as(first_approver)
    visit proposal_path(proposal)

    expect(page).not_to have_button('Approve')
  end

  def create_proposal
    @proposal ||= FactoryGirl.create(:proposal)
  end

  def create_approvals_for(users)
    users.each_with_index.map do |user, index|
      FactoryGirl.create(:approval, user: user, position: index + 1)
    end
  end

  def create_serial_approval(child_approvals)
    create_proposal.root_approval = Approvals::Parallel.new(child_approvals: child_approvals)
  end

  def approve_approval_for(user)
    create_proposal.individual_approvals.where(user: user).first.approve!
  end
end
