module ProposalSpecHelper
  def linear_approval_statuses(proposal)
    proposal.individual_approvals.pluck(:status)
  end

  def fully_approve(proposal)
    proposal.individual_approvals.each do |approval|
      approval.reload
      approval.approve!
    end
    expect(proposal.reload).to be_approved # sanity check

    # sanity checks
    expect(proposal.status).to eq('approved')
    expect(proposal.root_approval.status).to eq('approved')
    expect(linear_approval_statuses(proposal)).to eq(%w(
      approved
      approved
      approved
    ))

    deliveries.clear
  end
end
