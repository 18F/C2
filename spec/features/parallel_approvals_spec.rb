describe 'Parallel approvals' do
  it 'allows either approver to approve' do
    proposal = create(:proposal, :with_parallel_approvers)

    proposal.individual_approvals.each do |approval|
      login_as(approval.user)
      visit proposal_path(proposal)

      expect(page).to have_button('Approve')
    end
  end

  it 'does not allow the requester to approve' do
    proposal = create(:proposal, :with_parallel_approvers)

    login_as(proposal.requester)
    visit proposal_path(proposal)

    expect(page).not_to have_button('Approve')
  end
end
