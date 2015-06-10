class CommunicartMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  layout 'communicart_mailer'
  add_template_helper CommunicartMailerHelper
  add_template_helper ValueHelper
  add_template_helper ClientHelper
  add_template_helper MarkdownHelper


  # Approver can approve/reject/take other action
  def actions_for_approver(to_email, approval, alert_partial=nil)
    @show_approval_actions = true
    self.notification_for_approver(to_email, approval, alert_partial)
  end

  def notification_for_approver(to_email, approval, alert_partial=nil)
    @approval = approval
    @alert_partial = alert_partial
    proposal = approval.proposal

    from_email = user_email(proposal.requester)
    send_proposal_email(from_email, to_email, proposal, 'proposal_notification_email')
  end

  def proposal_observer_email(to_email, proposal)
    # TODO have the from_email be whomever triggered this notification
    send_proposal_email(sender, to_email, proposal)
  end

  def proposal_created_confirmation(proposal)
    to_email = proposal.requester.email_address
    send_proposal_email(sender, to_email, proposal)
  end

  def approval_reply_received_email(approval)
    proposal = approval.proposal
    @approval = approval
    @alert_partial = 'approvals_complete' if proposal.approved?

    from_email = user_email(approval.user)
    to_email = proposal.requester.email_address
    send_proposal_email(from_email, to_email, proposal)
  end

  def comment_added_email(comment, to_email)
    @comment = comment
    # Don't send if special comment
    if !@comment.update_comment
      from_email = user_email(comment.user)
      send_proposal_email(from_email, to_email, comment.proposal)
    end
  end


  private

  # for easier stubbing in tests
  def sender
    ENV['NOTIFICATION_FROM_EMAIL'] || 'noreply@some.gov'
  end

  def user_email(user)
    # http://stackoverflow.com/a/8106387/358804
    address = Mail::Address.new(sender)
    address.display_name = user.full_name
    address.format
  end

  def send_proposal_email(from_email, to_email, proposal, template_name=nil)
    @proposal = proposal.decorate

    # http://www.jwz.org/doc/threading.html
    headers['In-Reply-To'] = @proposal.email_msg_id
    headers['References'] = @proposal.email_msg_id

    mail(
      to: to_email,
      subject: @proposal.email_subject,
      from: from_email,
      template_name: template_name
    )
  end
end
