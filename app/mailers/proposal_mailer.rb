class ProposalMailer < ApplicationMailer
  layout "basic"
  add_template_helper ValueHelper

  def proposal_created_confirmation(proposal)
    @proposal = proposal.decorate
    assign_threading_headers(proposal)
    subject = "Request #{proposal.public_id}: #{proposal.name}"

    mail(
      to: proposal.requester.email_address,
      subject: subject,
      from: default_sender_email,
      reply_to: reply_email(proposal)
    )
  end
end
