module ProposalSpecHelper
  def linear_approval_statuses(proposal)
    proposal.individual_steps.pluck(:status)
  end

  def fully_approve(proposal)
    proposal.individual_steps.each do |approval|
      approval.reload
      approval.approve!
    end

    # sanity checks
    proposal.reload
    expect(proposal.status).to eq('approved')
    expect(proposal.root_step.status).to eq('approved')
    linear_approval_statuses(proposal).each do |status|
      expect(status).to eq('approved')
    end

    deliveries.clear
  end
end
