# This is a temporary way to handle a notification preference
# that will eventually be managed at the user level
# https://www.pivotaltracker.com/story/show/87656734
class NcrDispatcher < Dispatcher
  def requires_approval_notice?(approval)
    final_approval(approval.proposal) == approval
  end

  def final_approval(proposal)
    proposal.individual_steps.last
  end

  # Notify approvers who have already approved that this proposal has been
  # modified. Also notify current approvers that the proposal has been updated.
  # Do NOT notify the modifying user, if specified.
  # https://www.pivotaltracker.com/story/show/100957216
  def on_proposal_update(proposal, modifier = nil)
    notify_approvers(proposal, modifier)
    notify_pending_approvers(proposal, modifier)
    notify_observers(proposal, modifier)
    notify_requester(proposal, modifier)
  end

  private

  def notify_requester(proposal, modifier)
    return if proposal.requester == modifier
    CommunicartMailer.notification_for_subscriber(proposal.requester.email_address, proposal, "updated").deliver_later
  end

  def notify_approvers(proposal, modifier)
    proposal.individual_steps.approved.each do |approval|
      if modifier and approval.user.id == modifier.id
        next # no email for modifier
      end
      CommunicartMailer.notification_for_subscriber(approval.user_email_address, proposal, "already_approved", approval).deliver_later
    end
  end

  def notify_pending_approvers(proposal, modifier)
    proposal.currently_awaiting_steps.each do |approval|
      if modifier and approval.user.id == modifier.id
        next # no email for modifier
      end
      if approval.api_token # Approver's been notified through some other means
        CommunicartMailer.actions_for_approver(approval, "updated").deliver_later
      else
        CommunicartMailer.actions_for_approver(approval).deliver_later
      end
    end
  end

  def notify_observers(proposal, modifier)
    proposal.observers.each do |observer|
      if modifier and observer.id == modifier.id
        next # no email for modifier
      end
      if observer.role_on(proposal).active_observer?
        CommunicartMailer.notification_for_subscriber(observer.email_address, proposal, "updated").deliver_later
      end
    end
  end
end
