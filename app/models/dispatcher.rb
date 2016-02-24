class Dispatcher
  def self.deliver_new_proposal_emails(proposal)
    dispatcher = initialize_dispatcher(proposal)
    dispatcher.deliver_new_proposal_emails(proposal)
  end

  def self.on_approval_approved(approval)
    dispatcher = initialize_dispatcher(approval.proposal)
    dispatcher.on_approval_approved(approval)
  end

  def self.on_comment_created(comment)
    dispatcher = initialize_dispatcher(comment.proposal)
    dispatcher.on_comment_created(comment)
  end

  def self.email_step_user(step)
    dispatcher = initialize_dispatcher(step.proposal)
    dispatcher.email_step_user(step)
  end

  def self.on_proposal_update(proposal, modifier = nil)
    dispatcher = initialize_dispatcher(proposal)
    dispatcher.on_proposal_update(proposal, modifier)
  end

  def self.on_approver_removal(proposal, approvers)
    dispatcher = initialize_dispatcher(proposal)
    dispatcher.on_approver_removal(proposal, approvers)
  end

  def self.on_observer_added(observation, reason)
    dispatcher = initialize_dispatcher(observation.proposal)
    dispatcher.on_observer_added(observation, reason)
  end

  def self.deliver_attachment_emails(proposal, attachment)
    dispatcher = initialize_dispatcher(proposal)
    dispatcher.deliver_attachment_emails(proposal, attachment)
  end

  def self.initialize_dispatcher(proposal)
    if proposal.client_slug == "ncr"
      NcrDispatcher.new
    else
      LinearDispatcher.new
    end
  end

  def email_observers(proposal)
    active_observers = active_observers(proposal)
    active_observers.each do |observer|
      ObserverMailer.proposal_observer_email(observer.email_address, proposal).deliver_later
    end
  end

  def on_observer_added(observation, reason)
    ObserverMailer.on_observer_added(observation, reason).deliver_later
  end

  def deliver_new_proposal_emails(proposal)
    proposal.currently_awaiting_steps.each { |step| email_step_user(step) }

    email_observers(proposal)
    ProposalMailer.proposal_created_confirmation(proposal).deliver_later
  end

  def deliver_attachment_emails(proposal, attachment)
    proposal.subscribers_except_delegates.each do |user|
      step = proposal.steps.find_by(user: user)

      if user_is_not_step_user?(step) || step_user_knows_about_proposal?(step)
        AttachmentMailer.new_attachment_notification(user.email_address, proposal, attachment).deliver_later
      end
    end
  end

  def deliver_cancellation_emails(proposal, reason = nil)
    cancellation_notification_recipients = active_step_users(proposal) + active_observers(proposal)

    cancellation_notification_recipients.each do |recipient|
      CancellationMailer.cancellation_notification(recipient.email_address, proposal, reason).deliver_later
    end

    CancellationMailer.cancellation_confirmation(proposal, reason).deliver_later
  end

  def on_approval_approved(approval)
    if requires_approval_notice?(approval)
      ApprovalMailer.approval_reply_received_email(approval).deliver_later
    end

    email_observers(approval.proposal)
  end

  def on_comment_created(comment)
    comment.listeners.each do |user|
      CommentMailer.comment_added_notification(comment, user.email_address).deliver_later
    end
  end

  def on_proposal_update(_proposal)
  end

  def on_approver_removal(proposal, removed_approvers)
    removed_approvers.each do|approver|
      Mailer.notification_for_subscriber(approver.email_address, proposal, "removed").deliver_later
    end
  end

  private

  def email_step_user(step)
    send_notification_email(step)
  end

  def active_step_users(proposal)
    proposal.step_users.select do |user|
      proposal.is_active_step_user?(user)
    end
  end

  def active_observers(proposal)
    proposal.observers.select do |observer|
      observer.role_on(proposal).active_observer?
    end
  end

  def requires_approval_notice?(_approval)
    true
  end

  def send_notification_email(approval)
    Mailer.actions_for_approver(approval).deliver_later
  end

  def user_is_not_step_user?(step)
    step.blank?
  end

  def step_user_knows_about_proposal?(step)
    !step.pending?
  end
end
