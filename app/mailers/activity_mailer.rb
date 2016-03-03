class ActivityMailer < ApplicationMailer
  def activity_notification(user, proposal, activity)
    @activity = activity
    @proposal = proposal.decorate

    assign_threading_headers(@proposal)

    mail(
      to: email_to_user(user),
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end
end
