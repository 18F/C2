class ProposalMailerPreview < ActionMailer::Preview
  def proposal_created_confirmation
    ProposalMailer.proposal_created_confirmation(proposal)
  end

  private

  def proposal
    Proposal.last
  end
end
