class StepMailerPreview < ActionMailer::Preview
  include MailerPreviewHelpers

  def step_reply_received
    StepMailer.step_reply_received(completed_step)
  end

  def step_user_removed
    StepMailer.step_user_removed(user, proposal)
  end

  def proposal_notification
    StepMailer.proposal_notification(step)
  end
end
