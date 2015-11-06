module ProposalSpecHelper
  def fully_approve(proposal)
    proposal.individual_steps.each do |approval|
      approval.reload
      approval.approve!
    end
    expect(proposal.reload).to be_approved # sanity check
    deliveries.clear
  end
end
