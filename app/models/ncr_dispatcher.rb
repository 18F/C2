class NcrDispatcher < LinearDispatcher
  def deliver_new_proposal_emails(proposal)
    email_observers(proposal)

    if proposal.client_data.emergency?
      ProposalMailer.emergency_proposal_created_confirmation(proposal).deliver_later
    else
      proposal.currently_awaiting_steps.each { |step| email_step_user(step) }
      ProposalMailer.proposal_created_confirmation(proposal).deliver_later
    end
  end

  def requires_approval_notice?(approval)
    final_approval(approval.proposal) == approval
  end

  def final_approval(proposal)
    proposal.individual_steps.last
  end

  def on_proposal_update(proposal, modifier = nil)
    notify_approvers(proposal, modifier)
    notify_pending_approvers(proposal, modifier)
    notify_observers(proposal, modifier)
    notify_requester(proposal, modifier)
  end

  private

  def notify_requester(proposal, modifier)
    return if proposal.requester == modifier
    Mailer.notification_for_subscriber(proposal.requester.email_address, proposal, "updated").deliver_later
  end

  def notify_approvers(proposal, modifier)
    proposal.individual_steps.approved.each do |approval|
      if modifier and approval.user.id == modifier.id
        next # no email for modifier
      end
      Mailer.notification_for_subscriber(approval.user_email_address, proposal, "already_approved", approval).deliver_later
    end
  end

  def notify_pending_approvers(proposal, modifier)
    proposal.currently_awaiting_steps.each do |approval|
      if modifier and approval.user.id == modifier.id
        next # no email for modifier
      end
      if approval.api_token # Approver's been notified through some other means
        Mailer.actions_for_approver(approval, "updated").deliver_later
      else
        Mailer.actions_for_approver(approval).deliver_later
      end
    end
  end

  def notify_observers(proposal, modifier)
    proposal.observers.each do |observer|
      if modifier and observer.id == modifier.id
        next # no email for modifier
      end
      if observer.role_on(proposal).active_observer?
        Mailer.notification_for_subscriber(observer.email_address, proposal, "updated").deliver_later
      end
    end
  end
end
