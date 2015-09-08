# This is a temporary way to handle a notification preference
# that will eventually be managed at the user level
# https://www.pivotaltracker.com/story/show/87656734

class NcrDispatcher < LinearDispatcher

  def requires_approval_notice?(approval)
    final_approval(approval.proposal) == approval
  end

  def final_approval(proposal)
    proposal.individual_approvals.last
  end

  # Notify approvers who have already approved that this proposal has been
  # modified. Also notify current approvers that the proposal has been updated
  def on_proposal_update(proposal, modifier = nil)
    proposal.individual_approvals.approved.each{|approval|
      CommunicartMailer.notification_for_subscriber(approval.user_email_address, proposal, "already_approved", approval).deliver_later
    }

    proposal.currently_awaiting_approvals.each{|approval|
      if approval.api_token # Approver's been notified through some other means
        CommunicartMailer.actions_for_approver(approval, "updated").deliver_later
      else
        CommunicartMailer.actions_for_approver(approval).deliver_later
      end
    }

    proposal.observers.each{|observer|
      # don't notify the person who triggered the notification
      # https://www.pivotaltracker.com/story/show/100957216
      next if modifier and observer.id == modifier.id

      if observer.role_on(proposal).active_observer?
        CommunicartMailer.notification_for_subscriber(observer.email_address, proposal, "updated").deliver_later
      end
    }
  end
end
