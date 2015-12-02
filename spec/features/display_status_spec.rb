describe 'Display status text' do
  include ProposalSpecHelper

  it 'displays approved status' do
    proposal = create_proposal_with_approvers
    fully_approve(proposal)

    login_as(proposal.requester)
    visit proposals_path

    expect(page).to have_content('Approved')
  end

  it 'displays outstanding approvers' do
    proposal = create_proposal_with_approvers

    login_as(proposal.requester)
    visit proposals_path

    expect(page).not_to have_content('Please review')
    expect(page).to have_content('Waiting for review from:')
    expect(page).to have_content(proposal.approvers.first.full_name)
  end

  it 'excludes approved approvals' do
    proposal = create_proposal_with_approvers
    first_approval = proposal.individual_steps.first
    first_approval.approve!
    first_approver = first_approval.user
    last_approver = proposal.approvers.last

    login_as(proposal.requester)
    visit proposals_path

    expect(page).not_to have_content('Please review')
    expect(page).to have_content('Waiting for review from:')
    expect(page).not_to have_content(first_approver.full_name)
    expect(page).to have_content(last_approver.full_name)
  end

  context 'linear' do
    it 'displays the first approver' do
      proposal = create_proposal_with_two_approvers
      first_approval = proposal.individual_steps.first
      first_approver = first_approval.user
      all_approvers_except_first = proposal.approvers.offset(1)

      login_as(proposal.requester)
      visit proposals_path

      expect(page).to have_content('Waiting for review from:')
      expect(page).to have_content(first_approver.full_name)
      all_approvers_except_first.each do |approver|
        expect(page).not_to have_content(approver.full_name)
      end
    end

    it 'excludes approved approvals' do
      proposal = create_proposal_with_two_approvers
      first_approval = proposal.individual_steps.first
      first_approval.approve!
      first_approver = first_approval.user

      login_as(proposal.requester)
      visit proposals_path

      expect(page).to have_content('Waiting for review from:')
      expect(page).not_to have_content(first_approver.full_name)
    end
  end

  def create_proposal_with_approvers
    @proposal ||= create(:proposal, :with_two_approvers)
  end

  def create_proposal_with_two_approvers
    @proposal ||= create(:proposal, :with_two_approvers)
  end
end

