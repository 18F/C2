module Dispatcher
  def get_dispatcher(approval_group)
    # TODO switch based on flow
    # case approval_group.flow
    # when 'parallel'
    #   ParallelDispatcher
    # when 'linear'
    #   LinearDispatcher
    # end

    ParallelDispatcher
  end
  module_function :get_dispatcher

  def deliver_new_cart_emails(cart)
    dispatcher = self.get_dispatcher(cart.approval_group)
    dispatcher.deliver_new_cart_emails(cart)
  end
  module_function :deliver_new_cart_emails

  def deliver_approval_email(approval)
    dispatcher = self.get_dispatcher(approval.approval_group)
    dispatcher.deliver_approval_email(approval)
  end
  module_function :deliver_approval_email
end
