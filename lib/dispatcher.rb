class Dispatcher
  include ClassMethodsMixin

  def email_approver(approval)
    send_notification_email(approval)
  end

  def email_observers(proposal)
    active_observers = active_observers(proposal)
    active_observers.each do |observer|
      CommunicartMailer.proposal_observer_email(observer.email_address, proposal).deliver_later
    end
  end

  def on_observer_added(observation, reason)
    CommunicartMailer.on_observer_added(observation, reason).deliver_later
  end

  def email_sent_confirmation(proposal)
    CommunicartMailer.proposal_created_confirmation(proposal).deliver_later
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
      approval = proposal.steps.find_by(user_id: user.id)

      if user_is_not_approver?(approval) || approver_knows_about_proposal?(approval)
        CommunicartMailer.new_attachment_email(user.email_address, proposal).deliver_later
      end
    end
  end

  def deliver_cancellation_emails(proposal, reason = nil)
    cancellation_notification_recipients = active_approvers(proposal) + active_observers(proposal)

    cancellation_notification_recipients.each do |recipient|
      CommunicartMailer.cancellation_email(recipient.email_address, proposal, reason).deliver_later
    end

    CommunicartMailer.cancellation_confirmation(proposal).deliver_later
  end

  def on_approval_approved(approval)
    next_step = next_pending_approval(approval.proposal)

    if next_step
      email_approver(next_step)
    end

    if requires_approval_notice?(approval)
      CommunicartMailer.approval_reply_received_email(approval).deliver_later
    end

    self.email_observers(approval.proposal)
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
      CommunicartMailer.notification_for_subscriber(approver.email_address, proposal, "removed").deliver_later
    end
  end

  private

  def active_approvers(proposal)
    proposal.approvers.select do |approver|
      proposal.is_active_approver?(approver)
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
    CommunicartMailer.actions_for_approver(approval).deliver_later
  end

  def user_is_not_approver?(approval)
    approval.blank?
  end

  def approver_knows_about_proposal?(approval)
    !approval.pending?
  end

  def next_pending_approval(proposal)
    if proposal.pending?
      proposal.currently_awaiting_steps.first
    end
  end
end
