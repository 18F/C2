class CancellationMailerPreview < ActionMailer::Preview
  def cancellation_notification
    CancellationMailer.cancellation_notification(email, proposal, reason)
  end

  def cancellation_confirmation
    CancellationMailer.cancellation_confirmation(proposal, reason)
  end

  def proposal_fiscal_cancellation
    CancellationMailer.proposal_fiscal_cancellation(proposal)
  end

  private

  def email
    "test@example.com"
  end

  def reason
    "Example reason for cancelling proposal"
  end

  def proposal
    Proposal.last
  end
end
