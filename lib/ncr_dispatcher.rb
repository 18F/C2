# This is a temporary way to handle a notification preference
# that will eventually be managed at the user level
# https://www.pivotaltracker.com/story/show/87656734

class NcrDispatcher < LinearDispatcher

  def requires_approval_notice?(approval)
    final_approval(approval.cart) == approval
  end

  def final_approval(cart)
    cart.approvals.last
  end

  # Notify approvers who have already approved that this proposal has been
  # modified
  def on_proposal_update(proposal)
    proposal.approvals.approved.each{|approval|
      CommunicartMailer.cart_notification_email(
        approval.user_email_address, approval, false).deliver
    }
  end
end
