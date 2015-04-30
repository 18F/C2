class CommunicartMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  layout 'communicart_base'
  add_template_helper CommunicartMailerHelper
  add_template_helper ValueHelper
  add_template_helper ClientHelper


  def proposal_notification_email(to_email, approval, show_approval_actions=true)
    @approval = approval
    @show_approval_actions = show_approval_actions
    proposal = approval.proposal
    from_email = user_email(proposal.requester)
    send_proposal_email(from_email, to_email, proposal)
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
    to_address = @proposal.requester.email_address
    #TODO: Add a specific 'rejection' text block for the requester

    set_attachments(@proposal)

    mail(
         to: to_address,
         subject: "User #{approval.user.email_address} has #{approval.status} #{@proposal.public_identifier}",
         from: user_email(approval.user)
         )
  end

  def comment_added_email(comment, to_email)
    @comment = comment

    mail(
         to: to_email,
         subject: "A comment has been added to #{comment.proposal.public_identifier}",
         from: user_email(comment.user)
         )
  end

  private

  def set_attachments(proposal)
    if proposal.approved?
      attachments['Communicart' + proposal.public_identifier.to_s + '.comments.csv'] = Exporter::Comments.new(proposal).to_csv
      attachments['Communicart' + proposal.public_identifier.to_s + '.approvals.csv'] = Exporter::Approvals.new(proposal).to_csv
    end
  end

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

  def send_proposal_email(from_email, to_email, proposal)
    @proposal = proposal.decorate
    set_attachments(@proposal)

    mail(
      to: to_email,
      subject: "Communicart Approval Request from #{proposal.requester.full_name}: Please review #{proposal.public_identifier}",
      from: from_email
    )
  end
end
