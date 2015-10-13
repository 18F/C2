class Dispatcher
  include ClassMethodsMixin

  def email_approver(approval)
    send_notification_email(approval)
  end

  def email_observer(observation)
    proposal = observation.proposal
    CommunicartMailer.proposal_observer_email(observation.user_email_address, proposal).deliver_later
  end

  def email_observers(proposal)
    proposal.observations.each do |observation|
      user = observation.user
      if user.role_on(proposal).active_observer?
       email_observer(observation)
      end
    end
  end

  def on_observer_added(observation, reason)
    CommunicartMailer.on_observer_added(observation, reason).deliver_later
  end

  def email_sent_confirmation(proposal)
    CommunicartMailer.proposal_created_confirmation(proposal).deliver_later
  end

  def deliver_new_proposal_emails(proposal)
    proposal.currently_awaiting_approvals.each do |approval|
      email_approver(approval)
    end

    email_observers(proposal)
    email_sent_confirmation(proposal)
  end

  def deliver_attachment_emails(proposal)
    proposal.users.each do |user|
      approval = proposal.approvals.where(user: user)

      if approval_not_pending?(approval)
        CommunicartMailer.new_attachment_email(user.email_address, proposal).deliver_later
      end
    end
  end

  def deliver_cancellation_emails(proposal)
    proposal.individual_approvals.each do |approval|
      if approval_not_pending?(approval)
        CommunicartMailer.cancellation_email(approval.user_email_address, proposal).deliver_later
      end
    end

    CommunicartMailer.cancellation_confirmation(proposal).deliver_later
  end

  def on_approval_approved(approval)
    if requires_approval_notice?(approval)
      CommunicartMailer.approval_reply_received_email(approval).deliver_later
    end

    self.email_observers(approval.proposal)
  end

  def on_comment_created(comment)
    comment.listeners.each do |user|
      CommunicartMailer.comment_added_email(comment, user.email_address).deliver_later
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

  def requires_approval_notice?(_approval)
    true
  end

  def send_notification_email(approval)
    CommunicartMailer.actions_for_approver(approval).deliver_later
  end

  def approval_not_pending?(approval)
    approval && !approval.pending?
  end
end
