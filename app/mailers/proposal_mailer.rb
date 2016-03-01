class ProposalMailer < ApplicationMailer
  layout "basic"
  add_template_helper ValueHelper

  def proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    assign_threading_headers(proposal)

    mail(
      to: proposal.requester.email_address,
      subject: subject(proposal),
      from: default_sender_email,
      reply_to: reply_email(proposal)
    )
  end

  def emergency_proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    assign_threading_headers(proposal)

    mail(
      to: proposal.requester.email_address,
      subject: subject(proposal),
      from: default_sender_email,
      reply_to: reply_email(proposal)
    )
  end

  def proposal_complete(proposal)
    @proposal = proposal.decorate
    assign_threading_headers(proposal)

    mail(
      to: proposal.requester.email_address,
      subject: subject(proposal),
      from: default_sender_email,
      reply_to: reply_email(proposal)
    )
  end

  private

  def subject(proposal)
    "Request #{proposal.public_id}: #{proposal.name}"
  end
end
