class ParallelDispatcher < Dispatcher
  def deliver_approver_emails(cart)
    cart.approver_approvals.each do |approval|
      ApiToken.create!(user_id: approval.user_id, cart_id: cart.id, expires_at: Time.now + 7.days)
      CommunicartMailer.cart_notification_email(approval.user.email_address, cart, approval).deliver
    end
  end

  def deliver_observer_emails(cart)
    cart.approvals.where(role: 'observer').each do |observer|
      CommunicartMailer.cart_observer_email(observer.user.email_address, cart).deliver
    end
  end

  def deliver_new_cart_emails(cart)
    self.deliver_approver_emails(cart)
    self.deliver_observer_emails(cart)
  end

  def deliver_approval_email(approval)
    CommunicartMailer.approval_reply_received_email(approval).deliver
  end
end
