class ProposalMailerPreview < ActionMailer::Preview
  def proposal_created_confirmation
    ProposalMailer.proposal_created_confirmation(proposal)
  end

  def emergency_proposal_created_confirmation
    ProposalMailer.emergency_proposal_created_confirmation(proposal)
  end

  def proposal_complete
    ProposalMailer.proposal_complete(proposal)
  end

  def proposal_updated_step_complete
    ProposalMailer.proposal_updated_step_complete(step)
  end

  def proposal_updated_step_complete_needs_re_review
    ProposalMailer.proposal_updated_step_complete_needs_re_review(step)
  end

  private

  def proposal
    Proposal.last
  end

  def step
    Steps::Approval.last
  end
end
