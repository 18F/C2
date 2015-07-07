# This is a temporary way to handle a notification preference
# that will eventually be managed at the user level
# https://www.pivotaltracker.com/story/show/87656734

class NcrDispatcher < Dispatcher

  def requires_approval_notice?(approval)
    final_approval(approval.proposal) == approval
  end

  def final_approval(proposal)
    proposal.approvals.last
  end

  # Notify approvers who have already approved that this proposal has been
  # modified. Also notify current approvers that the proposal has been updated
  def on_proposal_update(proposal)
    proposal.user_approvals.approved.each{|approval|
      CommunicartMailer.notification_for_approver(approval.user_email_address, approval, "already_approved").deliver_now
    }
    proposal.user_approvals.actionable.each{|approval|
      if approval.api_token   # Approver's been notified through some other means
        CommunicartMailer.actions_for_approver(approval.user_email_address, approval, "updated").deliver_now
      else
        approval.create_api_token!
        CommunicartMailer.actions_for_approver(approval.user_email_address, approval).deliver_now
      end
    }
  end
end
