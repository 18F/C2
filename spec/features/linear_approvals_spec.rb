describe 'Linear approvals' do
  let(:create_proposal) { create(:proposal) }

  it 'allows the approver to approve' do
    proposal = create_proposal
    first_approver = create(:user)
    second_approver = create(:user)
    approvals = create_approvals_for([first_approver, second_approver])
    create_serial_approval(approvals)

    login_as(first_approver)
    visit proposal_path(proposal)

    expect(page).to have_button('Approve')
  end

  it 'does not allow the approver to approve twice' do
    proposal = create_proposal
    first_approver = create(:user)
    second_approver = create(:user)
    approvals = create_approvals_for([first_approver, second_approver])
    create_serial_approval(approvals)
    approve_approval_for(first_approver)

    login_as(first_approver)
    visit proposal_path(proposal)

    expect(page).not_to have_button('Approve')
  end

  it "shows the approver role next to each approver" do
    proposal = create(:proposal, :with_approval_and_purchase, client_slug: "gsa18f")
    approver = proposal.individual_steps.first.user
    login_as(approver)
    @proposal_page = ProposalPage.new
    @proposal_page.load(proposal_id: proposal.id)
    expect(@proposal_page).to be_displayed
    expect(@proposal_page.status).to have_approvers count: 2
    expect(@proposal_page.status.approvers.first.role.text).to match /Approver/
    expect(@proposal_page.status.approvers.second.role.text).to match /Purchaser/
  end

  def create_approvals_for(users)
    users.each_with_index.map do |user, index|
      create(:approval, user: user, position: index + 1)
    end
  end

  def create_serial_approval(child_steps)
    create_proposal.root_step = Steps::Serial.new(child_steps: child_steps)
  end

  def approve_approval_for(user)
    create_proposal.individual_steps.where(user: user).first.complete!
  end
end
