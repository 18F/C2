class MailPreview < MailView
  def actions_for_approver
    mail = CommunicartMailer.actions_for_approver(pending_approval)
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
    mail = CommentMailer.comment_added_email(comment, email)
    inline_styles(mail)
  end

  def on_observer_added
    mail = CommunicartMailer.on_observer_added(observation)
    inline_styles(mail)
  end

  def budget_status
    mail = ReportMailer.budget_status
    inline_styles(mail)
  end

  private

  def email
    'recipient@example.com'
  end

  def pending_approval
    Step.pending.last
  end

  def received_approval
    Step.approved.last
  end

  def proposal
    Proposal.last
  end

  def comment
    Comment.last
  end

  def observation
    Observation.last
  end

  ## https://github.com/Mange/roadie-rails/blob/v1.0.3/lib/roadie/rails/mailer.rb#L6 ##

  def inline_styles(mail)
    Roadie::Rails::MailInliner.new(mail, roadie_options).execute
  end

  def roadie_options
    ::Rails.application.config.roadie
  end

  #####################################################################################
end
