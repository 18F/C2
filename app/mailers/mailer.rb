class Mailer < ApplicationMailer
  layout "mailer"
  add_template_helper ValueHelper

  # Approver can approve/take other action
  def actions_for_approver(step, alert_partial = nil)
    @show_step_actions = true
    to_email = step.user_email_address
    proposal = step.proposal

    unless step.api_token
      step.create_api_token
    end

    notification_for_subscriber(to_email, proposal, alert_partial, step)
  end

  def notification_for_subscriber(to_email, proposal, alert_partial = nil, step = nil)
    @step = step.decorate if step
    @alert_partial = alert_partial

    send_proposal_email(
      from_email: user_email_with_name(proposal.requester),
      to_email: to_email,
      proposal: proposal,
      template_name: "proposal_notification_email"
    )
  end

  def general_proposal_email(to_email, proposal)
    # TODO have the from_email be whomever triggered this notification
    send_proposal_email(
      to_email: to_email,
      proposal: proposal
    )
  end

  alias_method :proposal_observer_email, :general_proposal_email
  alias_method :new_attachment_email, :general_proposal_email

  def proposal_created_confirmation(proposal)
    send_proposal_email(
      to_email: proposal.requester.email_address,
      proposal: proposal
    )
  end

  def approval_reply_received_email(approval)
    proposal = approval.proposal.reload
    @step = approval
    @alert_partial = "approvals_complete" if proposal.approved?

    send_proposal_email(
      from_email: user_email_with_name(approval.user),
      to_email: proposal.requester.email_address,
      proposal: proposal
    )
  end

  def resend(msg)
    @_message = Mail.new msg
    # we want to preserve the From name but not the email address, since gsa.gov
    # will block any @gsa.gov From address. We still use it intact in reply-to.
    from_raw = @_message.header["From"].value
    mail(
      subject: @_message.subject,
      to: resend_to_email,
      from: email_with_name(sender_email, Mail::Address.new(from_raw).display_name),
      reply_to: from_raw,
      "X-C2-Original-To" => @_message.header["To"].value,
      "X-C2-Original-From" => from_raw
    ) {} # no-op block so template error is avoided (body already in @_message)
  end
end
