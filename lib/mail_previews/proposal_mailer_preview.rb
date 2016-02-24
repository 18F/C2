class ProposalMailerPreview < ActionMailer::Preview
  def proposal_created_confirmation
    ProposalMailer.proposal_created_confirmation(proposal)
  end

  def emergency_proposal_created_confirmation
    ProposalMailer.emergency_proposal_created_confirmation(proposal)
  end

  private

  def proposal
    Proposal.last
  end
end
