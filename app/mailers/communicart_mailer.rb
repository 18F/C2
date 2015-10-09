class CommunicartMailer < ApplicationMailer
  include ProposalConversationThreading

  layout 'communicart_mailer'
  add_template_helper CommunicartMailerHelper
  add_template_helper ValueHelper
  add_template_helper ClientHelper
  add_template_helper MarkdownHelper

  # Approver can approve/take other action
  def actions_for_approver(approval, alert_partial = nil)
    @show_approval_actions = true
    to_email = approval.user_email_address
    proposal = approval.proposal

    unless approval.api_token
      approval.create_api_token!
    end

    self.notification_for_subscriber(to_email, proposal, alert_partial, approval)
  end

  def notification_for_subscriber(to_email, proposal, alert_partial = nil, approval = nil)
    @approval = approval
    @alert_partial = alert_partial

    send_proposal_email(
      from_email: user_email_with_name(proposal.requester),
      to_email: to_email,
      proposal: proposal,
      template_name: 'proposal_notification_email'
    )
  end

  def on_observer_added(observation, reason)
    @observation = observation
    @reason = reason
    observer = observation.user

    send_proposal_email(
      from_email: observation_added_from(observation),
      to_email: observer.email_address,
      proposal: observation.proposal
    )
  end

  def general_proposal_email(to_email, proposal)
    # TODO have the from_email be whomever triggered this notification
    send_proposal_email(
      to_email: to_email,
      proposal: proposal
    )
  end
  alias_method :cancellation_email, :general_proposal_email
  alias_method :proposal_observer_email, :general_proposal_email
  alias_method :new_attachment_email, :general_proposal_email

  def proposal_created_confirmation(proposal)
    send_proposal_email(
      to_email: proposal.requester.email_address,
      proposal: proposal
    )
  end
  alias_method :cancellation_confirmation, :proposal_created_confirmation

  def approval_reply_received_email(approval)
    proposal = approval.proposal.reload
    @approval = approval
    @alert_partial = 'approvals_complete' if proposal.approved?

    send_proposal_email(
      from_email: user_email_with_name(approval.user),
      to_email: proposal.requester.email_address,
      proposal: proposal
    )
  end

  def comment_added_email(comment, to_email)
    @comment = comment
    # Don't send if special comment
    unless @comment.update_comment
      send_proposal_email(
        from_email: user_email_with_name(comment.user),
        to_email: to_email,
        proposal: comment.proposal
      )
    end
  end

  def resend(msg)
    resent_to_addr = ENV['NOTIFICATION_FALLBACK_EMAIL'] || 'communicart.sender@gsa.gov'
    mail_msg = Mail.new msg
    mail_msg.header['X-C2-Original-To'] = mail_msg.to
    @_message = mail_msg
    # we want to preserve the From name but not the email address, since gsa.gov
    # will block any @gsa.gov From address. We still use it intact in reply-to.
    from_addr = Mail::Address.new(mail_msg.from)
    from_addr.address = sender_email
    mail(subject: mail_msg.subject, to: resent_to_addr, from: from_addr.format, reply_to: mail_msg.from) do |_fmt|
      # no-op block since our body is already set in @_message
    end
  end

  private

  def observation_added_from(observation)
    adder = observation.created_by
    if adder
      user_email_with_name(adder)
    else
      nil
    end
  end
end
