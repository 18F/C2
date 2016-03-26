class CancelationMailerPreview < ActionMailer::Preview
  include MailerPreviewHelpers

  def cancelation_notification
    CancelationMailer.cancelation_notification(
      canceler: user,
      proposal: canceled_proposal,
      reason: reason,
      recipient_email: email
    )
  end

  def cancelation_confirmation
    CancelationMailer.cancelation_confirmation(
      proposal: canceled_proposal,
      canceler: user,
      reason: reason
    )
  end

  def fiscal_cancelation_notification
    CancelationMailer.fiscal_cancelation_notification(canceled_proposal)
  end

  private

  def reason
    "Example reason for canceling proposal"
  end
end
