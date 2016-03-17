class CancelationMailerPreview < ActionMailer::Preview
  def cancelation_notification
    CancelationMailer.cancelation_notification(
      recipient_email: email,
      canceler: user,
      proposal: proposal,
      reason: reason
    )
  end

  def cancelation_confirmation
    CancelationMailer.cancelation_confirmation(
      proposal: proposal,
      canceler: user,
      reason: reason
    )
  end

  def fiscal_cancelation_notification
    CancelationMailer.fiscal_cancelation_notification(proposal)
  end

  private

  def email
    "test@example.com"
  end

  def user
    User.last
  end

  def reason
    "Example reason for canceling proposal"
  end

  def proposal
    Proposal.last
  end
end
