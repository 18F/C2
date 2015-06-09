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
    @proposal = proposal.decorate
    to_address = proposal.requester.email_address
    from_email = user_email(proposal.requester)

    mail(
         to: to_address,
         subject: "Your request for #{proposal.public_identifier} has been sent successfully.",
         from: from_email
         )
  end

  def approval_reply_received_email(approval)
    @approval = approval
    @proposal = approval.proposal.decorate
    @alert_partial = 'approvals_complete' if @proposal.approved?
    to_address = @proposal.requester.email_address

    mail(
         to: to_address,
         subject: "User #{approval.user.email_address} has #{approval.status} request #{@proposal.public_identifier}",
         from: user_email(approval.user)
         )
  end

  def comment_added_email(comment, to_email)
    @comment = comment
    # Don't send if special comment
    if !@comment.update_comment
      mail(
           to: to_email,
           subject: "A comment has been added to request #{comment.proposal.public_identifier}",
           from: user_email(comment.user)
           )
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
    mail(
      to: to_email,
      subject: "Communicart Approval Request from #{proposal.requester.full_name}: Please review request #{proposal.public_identifier}",
      from: from_email,
      template_name: template_name
    )
  end
end
