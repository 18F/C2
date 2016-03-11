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

  def proposal_updated_no_action_required
    ProposalMailer.proposal_updated_no_action_required(user, proposal, comment)
  end

  def proposal_updated_while_step_pending
    ProposalMailer.proposal_updated_while_step_pending(step, comment)
  end

  def proposal_updated_needs_re_review
    ProposalMailer.proposal_updated_needs_re_review(user, proposal, comment)
  end

  private

  def proposal
    Proposal.last
  end

  def step
    Steps::Approval.last
  end

  def user
    User.last
  end

  def comment
    Comment.last
  end
end
