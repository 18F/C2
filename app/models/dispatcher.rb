class Dispatcher
  def initialize(proposal)
    @proposal = proposal
  end

  def email_step_user(step)
    Mailer.actions_for_approver(step).deliver_later
  end

  def on_observer_added(observation, reason)
    ObserverMailer.on_observer_added(observation, reason).deliver_later
  end

  def deliver_new_proposal_emails
    proposal.currently_awaiting_steps.each do |step|
      email_step_user(step)
    end

    email_observers
    ProposalMailer.proposal_created_confirmation(proposal).deliver_later
  end

  def email_observers
    active_observers.each do |observer|
      ObserverMailer.proposal_observer_email(observer.email_address, proposal).deliver_later
    end
  end

  def deliver_attachment_emails(attachment)
    proposal.subscribers_except_delegates.each do |user|
      step = proposal.steps.find_by(user: user)

      if user_is_not_step_user?(step) || step_user_knows_about_proposal?(step)
        AttachmentMailer.new_attachment_notification(user.email_address, proposal, attachment).deliver_later
      end
    end
  end

  def deliver_cancellation_emails(reason)
    cancellation_notification_recipients = active_step_users + active_observers

    cancellation_notification_recipients.each do |recipient|
      CancellationMailer.cancellation_notification(recipient.email_address, proposal, reason).deliver_later
    end

    CancellationMailer.cancellation_confirmation(proposal, reason).deliver_later
  end

  def on_approval_approved(approval)
    if next_approval(approval)
      email_step_user(next_approval(approval))
    end

    if requires_approval_notice?(approval)
      ApprovalMailer.approval_reply_received_email(approval).deliver_later
    end

    email_observers
  end

  def on_comment_created(comment)
    comment.listeners.each do |user|
      CommentMailer.comment_added_notification(comment, user.email_address).deliver_later
    end
  end

  def on_proposal_update(modifier)
  end

  def on_approver_removal(removed_approvers)
    removed_approvers.each do|approver|
      Mailer.notification_for_subscriber(approver.email_address, proposal, "removed").deliver_later
    end
  end

  private

  attr_reader :proposal

  def active_step_users
    proposal.step_users.select do |user|
      proposal.is_active_step_user?(user)
    end
  end

  def active_observers
    proposal.observers.select do |observer|
      observer.role_on(proposal).active_observer?
    end
  end

  def requires_approval_notice?(approval)
    true
  end

  def user_is_not_step_user?(step)
    step.blank?
  end

  def step_user_knows_about_proposal?(step)
    !step.pending?
  end

  def next_approval(approval)
    if proposal.pending?
      proposal.currently_awaiting_steps.first
    end
  end
end
