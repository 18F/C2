class MailPreview < MailView
  def actions_for_approver
    # TODO mock access token, if one isn't present
    mail = CommunicartMailer.actions_for_approver(email, pending_approval)
    inline_styles(mail)
  end

  def proposal_observer_email
    mail = CommunicartMailer.proposal_observer_email(email, proposal)
    inline_styles(mail)
  end

  def approval_reply_received_email
    mail = CommunicartMailer.approval_reply_received_email(received_approval)
    inline_styles(mail)
  end

  def comment_added_email
    mail = CommunicartMailer.comment_added_email(comment, email)
    inline_styles(mail)
  end


  private

  def email
    'recipient@example.com'
  end

  def pending_approval
    Approval.pending.last
  end

  def received_approval
    Approval.where.not(status: 'pending').last
  end

  def proposal
    Proposal.last
  end

  def comment
    Comment.last
  end


  # https://github.com/Mange/roadie-rails/blob/v1.0.3/lib/roadie/rails/mailer.rb#L6

  def inline_styles(mail)
    Roadie::Rails::MailInliner.new(mail, roadie_options).execute
  end

  def roadie_options
    ::Rails.application.config.roadie
  end
end
