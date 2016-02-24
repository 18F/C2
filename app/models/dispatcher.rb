class Dispatcher
  def initialize(proposal)
    @proposal = proposal
  end

  def self.deliver_new_proposal_emails(proposal)
    self.new(proposal).deliver_new_proposal_emails
  end

  def self.deliver_attachment_emails(proposal, attachment)
    self.new(proposal).deliver_attachment_emails(attachment)
  end

  def self.deliver_cancellation_emails(proposal, reason = nil)
    self.new(proposal).deliver_cancellation_emails(reason)
  end

  def self.on_approval_approved(approval)
    self.new(approval.proposal).on_approval_approved(approval)
  end

  def self.on_comment_created(comment)
    self.new(comment.proposal).on_comment_created(comment)
  end

  def self.on_proposal_update(proposal, modifier = nil)
    self.new(proposal).on_proposal_update(modifier)
  end

  def self.on_approver_removal(proposal, approvers)
    self.new(proposal).on_approver_removal(approvers)
  end

  def self.on_observer_added(observation, reason)
    self.new(observation.proposal).on_observer_added(observation, reason)
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
    if proposal.client_slug == "ncr"
      notify_approvers(modifier)
      notify_pending_approvers(modifier)
      notify_requester(modifier)
      notify_observers(modifier)
    end
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
    if proposal.client_slug == "ncr"
      final_approval == approval
    else
      true
    end
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

  def final_approval
    proposal.individual_steps.last
  end

  def notify_approvers(modifier)
    proposal.individual_steps.approved.each do |approval|
      unless user_is_modifier?(approval.user, modifier)
        Mailer.notification_for_subscriber(
          approval.user_email_address,
          proposal,
          "already_approved",
          approval
        ).deliver_later
      end
    end
  end

  def notify_requester(modifier)
    if proposal.requester != modifier
      Mailer.notification_for_subscriber(proposal.requester.email_address, proposal, "updated").deliver_later
    end
  end

  def notify_pending_approvers(modifier)
    proposal.currently_awaiting_steps.each do |approval|
      unless user_is_modifier?(approval.user, modifier)
        if approval.api_token # Approver's been notified through some other means
          Mailer.actions_for_approver(approval, "updated").deliver_later
        else
          Mailer.actions_for_approver(approval).deliver_later
        end
      end
    end
  end

  def notify_observers(modifier)
    proposal.observers.each do |observer|
      unless user_is_modifier?(observer, modifier)
        if observer.role_on(proposal).active_observer?
          Mailer.notification_for_subscriber(observer.email_address, proposal, "updated").deliver_later
        end
      end
    end
  end

  def user_is_modifier?(user, modifier)
    modifier && user == modifier
  end
end
