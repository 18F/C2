class ParallelDispatcher < Dispatcher
  def email_all_approvers(cart)
    cart.approver_approvals.each do |approval|
      ApiToken.create!(user_id: approval.user_id, cart_id: cart.id, expires_at: Time.now + 7.days)
      CommunicartMailer.cart_notification_email(approval.user.email_address, cart, approval).deliver
    end
  end

  def deliver_new_cart_emails(cart)
    self.email_all_approvers(cart)
    self.email_observers(cart)
  end
end
