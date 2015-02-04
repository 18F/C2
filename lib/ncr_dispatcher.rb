class NcrDispatcher < LinearDispatcher

  def requires_approval_notice?(approval)
    final_approval(approval.cart) == approval
  end

  def final_approval(cart)
    cart.ordered_approvals.last
  end
end