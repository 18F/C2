class ApprovalMailer < ApplicationMailer
  layout "basic"
  add_template_helper ValueHelper

  def approval_reply_received_email(step)
    proposal = step.proposal.reload
    @step = step

    send_proposal_email(
      from_email: user_email_with_name(step.user),
      to_email: proposal.requester.email_address,
      proposal: proposal
    )
  end

  def approver_removed(to_email, proposal)
    @proposal = proposal.decorate
    assign_threading_headers(@proposal)

    mail(
      to: to_email,
      subject: subject(@proposal),
      from: user_email_with_name(@proposal.requester),
      reply_to: reply_email(@proposal)
    )
  end

  private

  def subject(proposal)
    "Request #{proposal.public_id}: #{proposal.name}"
  end
end
