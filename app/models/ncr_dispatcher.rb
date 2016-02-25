class NcrDispatcher < Dispatcher
  def on_proposal_update(modifier = nil)
    notify_approvers(modifier)
    notify_pending_approvers(modifier)
    notify_requester(modifier)
    notify_observers(modifier)
  end

  private

  def requires_approval_notice?(approval)
    final_approval == approval
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
