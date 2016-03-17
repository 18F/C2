class Dispatcher
  def initialize(proposal)
    @proposal = proposal
  end

  def on_observer_added(observation, reason)
    ObserverMailer.observer_added_notification(observation, reason).deliver_later
  end

  def on_observer_removed(user)
    ObserverMailer.observer_removed_notification(proposal, user).deliver_later
  end

  def deliver_new_proposal_emails
    proposal.currently_awaiting_steps.each do |step|
      StepMailer.proposal_notification(step).deliver_later
    end

    ProposalMailer.proposal_created_confirmation(proposal).deliver_later
  end

  def deliver_attachment_emails(attachment)
    recipients = proposal.subscribers_except_delegates - [attachment.user]
    recipients.each do |user|
      step = proposal.steps.find_by(user: user)

      if user_is_not_step_user?(step) || step_user_knows_about_proposal?(step)
        AttachmentMailer.new_attachment_notification(user.email_address, proposal, attachment).deliver_later
      end
    end
  end

  def deliver_cancelation_emails(canceler, reason = nil)
    cancelation_notification_recipients = [proposal.requester] + active_step_users + active_observers - [canceler]

    cancelation_notification_recipients.each do |recipient|
      CancelationMailer.cancelation_notification(
        recipient_email: recipient.email_address,
        canceler: canceler,
        proposal: proposal,
        reason: reason
      ).deliver_later
    end

    CancelationMailer.cancelation_confirmation(
      canceler: canceler,
      proposal: proposal,
      reason: reason
    ).deliver_later
  end

  def step_complete(step)
    if next_step.present?
      StepMailer.proposal_notification(next_step).deliver_later
    end

    if requires_approval_notice? && proposal.reload.pending?
      StepMailer.step_reply_received(step).deliver_later
    elsif proposal.completed?
      proposal.observers.each { |observer| ObserverMailer.proposal_complete(observer, proposal).deliver_later }
      ProposalMailer.proposal_complete(step.proposal).deliver_later
    end
  end

  def on_comment_created(comment)
    comment.listeners.each do |user|
      CommentMailer.comment_added_notification(comment, user.email_address).deliver_later
    end
  end

  def on_proposal_update(modifier: nil, needs_reapproval: false)
  end

  def on_step_user_removal(removed_step_users)
    removed_step_users.each do |user|
      StepMailer.step_user_removed(user, proposal).deliver_later
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

  def requires_approval_notice?
    true
  end

  def user_is_not_step_user?(step)
    step.blank?
  end

  def step_user_knows_about_proposal?(step)
    !step.pending?
  end

  def next_step
    proposal.currently_awaiting_steps.first
  end
end
