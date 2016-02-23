class ApprovalMailer < ApplicationMailer
  layout "mailer"
  add_template_helper ValueHelper

  def approval_reply_received_email(approval)
    proposal = approval.proposal.reload
    @step = approval

    send_proposal_email(
      from_email: user_email_with_name(approval.user),
      to_email: proposal.requester.email_address,
      proposal: proposal
    )
  end
end
