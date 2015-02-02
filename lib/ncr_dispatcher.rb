class NcrDispatcher < LinearDispatcher

  def requires_approval_notice? approval
    [approval.cart_approvals.first, approval.cart_approvals.last].include? approval
  end
end