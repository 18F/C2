class CancelationMailer < ApplicationMailer
  def cancelation_notification(recipient_email:, canceler:, proposal:, reason: nil)
    add_inline_attachment("icon-pencil-circle.png")
    add_inline_attachment("button-x-circled.png")
    @reason = reason
    @user = canceler
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: recipient_email,
      subject: subject(@proposal),
      from: user_email_with_name(@proposal.requester),
      reply_to: reply_email(@proposal)
    )
  end

  def cancelation_confirmation(canceler:, proposal:, reason: nil)
    add_inline_attachment("button-x-circled.png")
    add_inline_attachment("icon-pencil-circle.png")
    @user = canceler
    @reason = reason
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: @user.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def fiscal_cancelation_notification(proposal)
    add_inline_attachment("icon-pencil-circle.png")
    @proposal = proposal.decorate
    user = @proposal.requester

    mail(
      to: email_to_user(user),
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end
end
