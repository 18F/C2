class LinearDispatcher < Dispatcher
  def next_pending_approval(cart)
    # we don't care how the cart was approved/rejected
    if cart.pending?
      return cart.ordered_awaiting_approvals.first
    end
  end

  def email_next_pending_approver(cart)
    if approval = self.next_pending_approval(cart)
      self.email_approver(approval)
    end
  end

  def deliver_new_cart_emails(cart)
    self.email_next_pending_approver(cart)
    super
  end

  def on_approval_status_change(approval)
    self.email_next_pending_approver(approval.cart)
    super
  end
end
