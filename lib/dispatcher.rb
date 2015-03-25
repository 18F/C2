class Dispatcher
  def email_approver(approval)
    approval.create_api_token!
    send_notification_email(approval)
  end

  def email_observers(cart)
    cart.approvals.observing.each do |observer|
      CommunicartMailer.cart_observer_email(observer.user_email_address, cart).deliver
    end
  end

  def email_sent_confirmation(cart)
    CommunicartMailer.proposal_created_confirmation(cart).deliver
  end

  def deliver_new_cart_emails(cart)
    self.email_observers(cart)
    self.email_sent_confirmation(cart)
  end

  def requires_approval_notice?(approval)
    true
  end

  def on_cart_rejected(cart)
    rejection = cart.rejections.first
    # @todo rewrite this email so a "rejection approval" isn't needed
    CommunicartMailer.approval_reply_received_email(rejection).deliver
    self.email_observers(cart)
  end

  def on_approval_approved(approval)
    if self.requires_approval_notice?(approval)
      CommunicartMailer.approval_reply_received_email(approval).deliver
    end

    self.email_observers(approval.cart)
  end

  def on_cart_comment_created(comment)
    self.all_users_for_cart(comment.commentable).each{|user|
      # Commenter doesn't need to see the message again
      if user != comment.user
        CommunicartMailer.comment_added_email(
          comment, user.email_address).deliver
      end
    }
  end

  # todo: replace with dynamic dispatch
  def self.initialize_dispatcher(cart)
    case cart.flow
    when 'parallel'
      ParallelDispatcher.new
    when 'linear'
      # @todo: dynamic dispatch for selection
      if cart.proposal.client == "ncr"
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

  def self.on_cart_rejected(cart)
    dispatcher = self.initialize_dispatcher(cart)
    dispatcher.on_cart_rejected(cart)
  end

  def self.on_approval_approved(approval)
    dispatcher = self.initialize_dispatcher(approval.cart)
    dispatcher.on_approval_approved(approval)
  end

  def self.on_cart_comment_created(comment)
    dispatcher = self.initialize_dispatcher(comment.commentable)
    dispatcher.on_cart_comment_created(comment)
  end

  protected

  def all_users_for_cart(cart)
    users_to_notify = cart.currently_awaiting_approvers
    if cart.requester
      users_to_notify << cart.requester
    end
    users_to_notify + cart.approvals.observing.map(&:user)
  end

  private

  def send_notification_email(approval)
    email = approval.user_email_address
    CommunicartMailer.cart_notification_email(email, approval).deliver
  end
end
