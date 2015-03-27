class ParallelDispatcher < Dispatcher
  def email_all_approvers(cart)
    cart.approvals.each do |approval|
      self.email_approver(approval)
    end
  end

  def deliver_new_cart_emails(cart)
    self.email_all_approvers(cart)
    super
  end
end
