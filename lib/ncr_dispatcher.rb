# This is a temporary way to handle a notification preference
# that will eventually be managed at the user level
# https://www.pivotaltracker.com/story/show/87656734

class NcrDispatcher < LinearDispatcher

  def requires_approval_notice?(approval)
    final_approval(approval.cart) == approval
  end

  def final_approval(cart)
    cart.approvals.ordered.last
  end
end
