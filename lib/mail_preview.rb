class MailPreview < MailView
  def cart_notification_email
    CommunicartMailer.cart_notification_email(email, approval)
  end

  def cart_observer_email
    CommunicartMailer.cart_observer_email(email, cart)
  end

  def approval_reply_received_email
    CommunicartMailer.approval_reply_received_email(approval)
  end

  def comment_added_email
    CommunicartMailer.comment_added_email(comment, email)
  end


  private

  def email
    'recipient@example.com'
  end

  def approval
    Approval.last
  end

  def cart
    Cart.last
  end

  def comment
    Comment.last
  end
end
