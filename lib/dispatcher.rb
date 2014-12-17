class Dispatcher
  def email_approver(approval)
    cart = approval.cart
    ApiToken.create!(user_id: approval.user_id, cart_id: cart.id, expires_at: Time.now + 7.days)
    send_notification_email(approval)
  end

  def email_observers(cart)
    cart.approvals.where(role: 'observer').each do |observer|
      CommunicartMailer.cart_observer_email(observer.user.email_address, cart).deliver
    end
  end

  def deliver_new_cart_emails(cart)
    self.email_observers(cart)
  end

  def on_approval_status_change(approval)
    CommunicartMailer.approval_reply_received_email(approval).deliver
    self.email_observers(approval.cart)
  end

  def self.initialize_dispatcher(cart)
    case cart.flow
    when 'parallel'
      ParallelDispatcher.new
    when 'linear'
      LinearDispatcher.new
    end
  end

  def self.deliver_new_cart_emails(cart)
    dispatcher = self.initialize_dispatcher(cart)
    dispatcher.deliver_new_cart_emails(cart)
  end

  def self.on_approval_status_change(approval)
    dispatcher = self.initialize_dispatcher(approval.cart)
    dispatcher.on_approval_status_change(approval)
  end


  private

  def send_notification_email(approval)
    email = approval.user.email_address
    CommunicartMailer.cart_notification_email(email, approval).deliver
  end
end
