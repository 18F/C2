class LinearDispatcher < Dispatcher
  def next_approval(cart)
    cart.ordered_awaiting_approvals.first
  end

  def email_next_approver(cart)
    if approval = self.next_approval(cart)
      self.email_approver(approval)
    end
  end

  def deliver_new_cart_emails(cart)
    self.email_next_approver(cart)
    super
  end

  def on_approval_status_change(approval)
    self.email_next_approver(approval.cart)
    super
  end
end
