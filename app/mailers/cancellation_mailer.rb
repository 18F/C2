class CancellationMailer < ApplicationMailer
  include ProposalConversationThreading

  layout "basic"

  def cancellation_notification(to_email, proposal, reason = nil)
    @reason = reason
    @proposal = proposal.decorate

    mail(
      to: to_email,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def cancellation_confirmation(proposal, reason)
    @reason = reason
    @proposal = proposal.decorate

    mail(
      to: proposal.requester.email_address,
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  def fiscal_cancellation_notification(proposal)
    @proposal = proposal.decorate
    user = @proposal.requester

    mail(
      to: email_with_name(user.email_address, user.full_name),
      subject: subject(@proposal),
      from: default_sender_email,
      reply_to: reply_email(@proposal)
    )
  end

  private

  def subject(proposal)
    "Request #{proposal.public_id} cancelled: #{proposal.name}"
  end
end
