class NcrDispatcher < LinearDispatcher

  def requires_approval_notice? approval
    [approval.cart.approvals.first, approval.cart.approvals.last].include? approval
  end
end