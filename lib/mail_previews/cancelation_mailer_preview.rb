class CancelationMailerPreview < ActionMailer::Preview
  def cancelation_notification
    CancelationMailer.cancelation_notification(email, proposal, reason)
  end

  def cancelation_confirmation
    CancelationMailer.cancelation_confirmation(proposal, reason)
  end

  def fiscal_cancelation_notification
    CancelationMailer.fiscal_cancelation_notification(proposal)
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
