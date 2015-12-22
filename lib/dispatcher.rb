class Dispatcher
  include ClassMethodsMixin

  def email_approver(approval)
    send_notification_email(approval)
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

  def email_sent_confirmation(proposal)
    Mailer.proposal_created_confirmation(proposal).deliver_later
  end

  def deliver_new_proposal_emails(proposal)
    proposal.currently_awaiting_steps.each do |approval|
      email_approver(approval)
    end

    email_observers(proposal)
    email_sent_confirmation(proposal)
  end

  def deliver_attachment_emails(proposal)
    proposal.subscribers_except_delegates.each do |user|
      step = proposal.steps.find_by(user_id: user.id)

      if user_is_not_step_user?(step) || step_user_knows_about_proposal?(step)
        Mailer.new_attachment_email(user.email_address, proposal).deliver_later
      end
    end
  end

  def deliver_cancellation_emails(proposal, reason = nil)
    cancellation_notification_recipients = active_step_users(proposal) + active_observers(proposal)

    cancellation_notification_recipients.each do |recipient|
      CancellationMailer.cancellation_email(recipient.email_address, proposal, reason).deliver_later
    end

    CancellationMailer.cancellation_confirmation(proposal).deliver_later
  end

  def on_approval_approved(approval)
    if requires_approval_notice?(approval)
      Mailer.approval_reply_received_email(approval).deliver_later
    end

    email_observers(approval.proposal)
  end

  def on_comment_created(comment)
    comment.listeners.each do |user|
      CommentMailer.comment_added_email(comment, user.email_address).deliver_later
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

  def active_step_users(proposal)
    proposal.approvers_and_purchasers.select do |user|
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
