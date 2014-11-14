class Dispatcher
  def email_approver(approval)
    cart = approval.cart
    ApiToken.create!(user_id: approval.user_id, cart_id: cart.id, expires_at: Time.now + 7.days)
    CommunicartMailer.cart_notification_email(approval.user.email_address, cart, approval).deliver
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

  def self.get_dispatcher(approval_group)
    # TODO switch based on flow
    # case approval_group.flow
    # when 'parallel'
    #   ParallelDispatcher
    # when 'linear'
    #   LinearDispatcher
    # end

    ParallelDispatcher.new
  end

  def self.deliver_new_cart_emails(cart)
    dispatcher = self.get_dispatcher(cart.approval_group)
    dispatcher.deliver_new_cart_emails(cart)
  end

  def self.on_approval_status_change(approval)
    dispatcher = self.get_dispatcher(approval.approval_group)
    dispatcher.on_approval_status_change(approval)
  end
end
