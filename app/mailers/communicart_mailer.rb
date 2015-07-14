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

    send_proposal_email(
      from_email: user_email_with_name(proposal.requester),
      to_email: to_email,
      proposal: proposal,
      template_name: 'proposal_notification_email'
    )
  end

  def proposal_observer_email(to_email, proposal)
    # TODO have the from_email be whomever triggered this notification
    send_proposal_email(
      to_email: to_email,
      proposal: proposal
    )
  end

  def proposal_created_confirmation(proposal)
    send_proposal_email(
      to_email: proposal.requester.email_address,
      proposal: proposal
    )
  end

  def approval_reply_received_email(approval)
    proposal = approval.proposal
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
    if !@comment.update_comment
      send_proposal_email(
        from_email: user_email_with_name(comment.user),
        to_email: to_email,
        proposal: comment.proposal
      )
    end
  end

  def feedback(sending_user, form_values)
    form_strings = form_values.map { |pair| "#{pair[0]}: #{pair[1]}" }
    message = form_strings.join("\n")
    mail(
      to: CommunicartMailer.support_email,
      subject: 'Feedback submission',
      from: default_sender_email,
      body: message,
      cc: sending_user.try(:email_address)
    )
  end

  def self.support_email
    ENV['SUPPORT_EMAIL'] || 'gatewaycommunicator@gsa.gov'   # not sensitive, so hard coding
  end

  private

  def email_with_name(email, name)
    # http://stackoverflow.com/a/8106387/358804
    address = Mail::Address.new(email)
    address.display_name = name
    address.format
  end

  def sender_email
    ENV['NOTIFICATION_FROM_EMAIL'] || 'noreply@some.gov'
  end

  def default_sender_email
    email_with_name(sender_email, "Communicart")
  end

  def user_email_with_name(user)
    email_with_name(sender_email, user.full_name)
  end

  # `proposal` and `to_email` are required
  def send_proposal_email(proposal: nil, to_email: nil, from_email: nil, template_name: nil)
    @proposal = proposal.decorate

    # http://www.jwz.org/doc/threading.html
    headers['In-Reply-To'] = @proposal.email_msg_id
    headers['References'] = @proposal.email_msg_id

    mail(
      to: to_email,
      subject: proposal_subject(@proposal),
      from: from_email || default_sender_email,
      template_name: template_name
    )
  end

  def proposal_subject(proposal)
    params = proposal.as_json
    #todo: replace with public_id once #98376564 is fixed
    params[:public_identifier] = proposal.public_identifier
    # Add in requester params
    proposal.requester.as_json.each { |k, v| params["requester_" + k] = v }
    if proposal.client_data
      # We'll look up by the client_data's class name
      i18n_key = proposal.client_data.class.name.underscore
      # Add in client_data params
      params.merge!(proposal.client_data.as_json)
    else
      # Default (no client_data): look up by "proposal"
      i18n_key = :proposal
    end
    # Add search path, and default lookup key for I18n
    params.merge!(scope: [:mail, :subject], default: :proposal)
    I18n.t i18n_key, params.symbolize_keys
  end
end
