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

    deliver_proposal_created_confirmation
  end

  def deliver_attachment_emails(attachment)
    recipients = proposal.subscribers_except_delegates - [attachment.user]
    recipients.each do |user|
      step = proposal.steps.find_by(user: user)

      if user_is_not_step_user?(step) || step_user_knows_about_proposal?(step)
        AttachmentMailer.new_attachment_notification(user, proposal, attachment).deliver_later
      end
    end
  end

  def deliver_cancelation_emails(canceler, reason = nil)
    cancelation_notification_recipients = [proposal.requester] + active_step_users + only_observers - [canceler]

    cancelation_notification_recipients.each do |recipient|
      CancelationMailer.cancelation_notification(
        recipient: recipient,
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

    if requires_approval_notice? && proposal.pending?
      StepMailer.step_reply_received(step).deliver_later
    elsif proposal.completed?
      only_observers.each { |observer| ObserverMailer.proposal_complete(observer, proposal).deliver_later }
      ProposalMailer.proposal_complete(step.proposal).deliver_later
    end
  end

  def on_comment_created(comment)
    comment_subscribers(comment).each do |user|
      CommentMailer.comment_added_notification(comment, user).deliver_later
    end
  end

  def on_proposal_update(needs_review:, comment:)
    notify_approvers(needs_review, comment)
    notify_pending_approvers(comment)
    notify_requester(needs_review, comment)
    notify_observers(needs_review, comment)
  end

  def on_step_user_removal(removed_step_users)
    removed_step_users.each do |user|
      StepMailer.step_user_removed(user, proposal).deliver_later
    end
  end

  private
  
  def notify_approvers(needs_review, comment)
    proposal.individual_steps.completed.each do |step|
      unless user_is_modifier?(step.user, comment.user)
        # TODO Remove
        # rubocop:disable Style/Next
        if needs_review == false
          ProposalMailer.
            proposal_updated_no_action_required(step.user, proposal, comment).
            deliver_later
        end
      end
    end
  end

  # TODO Remove
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def notify_requester(needs_review, comment)
    if proposal.requester != comment.user
      if needs_review == true
        ProposalMailer.
          proposal_updated_needs_re_review(proposal.requester, proposal, comment).
          deliver_later
      else
        ProposalMailer.
          proposal_updated_no_action_required(proposal.requester, proposal, comment).
          deliver_later
      end
    end
  end

  def notify_pending_approvers(comment)
    proposal.currently_awaiting_steps.each do |step|
      unless user_is_modifier?(step.user, comment.user)
        if step_user_already_notified_about_proposal?(step)
          ProposalMailer.proposal_updated_while_step_pending(step, comment).deliver_later
        else
          StepMailer.proposal_notification(step).deliver_later
        end
      end
    end
  end

  def notify_observers(needs_review, comment)
    only_observers.each do |observer|
      unless user_is_modifier?(observer, comment.user)
        if observer.role_on(proposal).observer_only?
          if needs_review == true
            ProposalMailer.
              proposal_updated_needs_re_review(observer, proposal, comment).
              deliver_later
          else
            ProposalMailer.
              proposal_updated_no_action_required(observer, proposal, comment).
              deliver_later
          end
        end
      end
    end
  end

  def user_is_modifier?(user, comment_user)
    user == comment_user
  end

  def step_user_already_notified_about_proposal?(step)
    step.api_token.present?
  end


  attr_reader :proposal

  def active_step_users
    proposal.step_users.select do |user|
      proposal.is_active_step_user?(user)
    end
  end

  def only_observers
    proposal.observers.select do |observer|
      observer.role_on(proposal).observer_only?
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
    proposal.reload.currently_awaiting_steps.first
  end

  def deliver_proposal_created_confirmation
    ProposalMailer.proposal_created_confirmation(proposal).deliver_later
  end

  def comment_subscribers(comment)
    proposal.subscribers_except_future_step_users - [comment.user]
  end
end
