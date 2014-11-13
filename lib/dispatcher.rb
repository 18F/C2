class Dispatcher
  def deliver_new_cart_emails(cart)
    raise "Must be implemented by subclass"
  end

  def deliver_approval_email(approval)
    raise "Must be implemented by subclass"
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

  def self.deliver_approval_email(approval)
    dispatcher = self.get_dispatcher(approval.approval_group)
    dispatcher.deliver_approval_email(approval)
  end
end
