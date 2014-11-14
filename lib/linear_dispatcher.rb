class LinearDispatcher < Dispatcher
  def ordered_approvals(cart)
    cart.awaiting_approvals.order('position ASC')
  end

  def next_approval(cart)
    self.ordered_approvals(cart).first
  end

  def deliver_new_cart_emails(cart)
    approval = self.next_approval(cart)
    if approval
      self.email_approver(approval)
    end

    super
  end
end
