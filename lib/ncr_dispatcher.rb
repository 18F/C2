class NcrDispatcher < LinearDispatcher

  def requires_approval_notice? approval
    approval.cart_approvals.approvable.order('position ASC').last == approval
  end
end