class ApprovalMailer < ApplicationMailer
  layout "mailer"
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
end
