class CancelationMailer < ApplicationMailer
  def cancelation_notification(to_email, proposal, reason = nil)
    @reason = reason
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: to_email,
      subject: subject(@proposal),
      from: user_email_with_name(@proposal.requester),
      reply_to: reply_email(@proposal)
    )
  end

  def cancelation_confirmation(proposal, reason)
    @reason = reason
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: proposal.requester.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def fiscal_cancelation_notification(proposal)
    @proposal = proposal.decorate

    mail(
      to: @proposal.requester.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  private

  def subject(proposal)
    "Request #{proposal.public_id} canceled: #{proposal.name}"
  end
end
