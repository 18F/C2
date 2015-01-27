class Dispatcher
  def email_approver(approval)
    approval.create_api_token!
    send_notification_email(approval)
  end

  def email_observers(cart)
    cart.approvals.where(role: 'observer').each do |observer|
      CommunicartMailer.cart_observer_email(observer.user_email_address, cart).deliver
    end
  end

  def deliver_new_cart_emails(cart)
    self.email_observers(cart)
  end

  def on_approval_status_change(approval)
    CommunicartMailer.approval_reply_received_email(approval).deliver if self.requires_approval_notice? approval

    self.email_observers(approval.cart)
  end

  def requires_approval_notice?(approval)
    true
  end

  def self.initialize_dispatcher(cart)
    case cart.flow
    when 'parallel'
      ParallelDispatcher.new
    when 'linear'
      if cart.getProp('origin') == 'ncr'
        NcrDispatcher.new
      else
        LinearDispatcher.new
      end
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
    email = approval.user_email_address
    CommunicartMailer.cart_notification_email(email, approval).deliver
  end
end
