class CommunicartMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  layout 'communicart_base'
  add_template_helper CommunicartMailerHelper


  def cart_notification_email(email, approval)
    @approval = approval
    send_cart_email(email, approval.cart)
  end

  def cart_observer_email(email, cart)
    send_cart_email(email, cart)
  end

  def sent_confirmation_email(cart)
    @cart = cart.decorate
    @user = cart.requester
  end

  def approval_reply_received_email(approval)
    cart = approval.cart
    @approval = approval
    @cart = cart.decorate
    to_address = cart.requester.email_address
    #TODO: Add a specific 'rejection' text block for the requester

    set_attachments(cart)

    mail(
         to: to_address,
         subject: "User #{approval.user.email_address} has #{approval.status} cart ##{cart.external_id}",
         from: from_email
         )
  end

  def comment_added_email(comment, to_email)
    @comment_text = comment.comment_text
    @cart_item = comment.commentable

    mail(
         to: to_email,
         subject: "A comment has been added to cart item '#{@cart_item.description}'",
         from: from_email
         )
  end


  private

  def set_attachments(cart)
    if cart.all_approvals_received?
      attachments['Communicart' + cart.name + '.details.csv'] = Exporter::Items.new(cart).to_csv
      attachments['Communicart' + cart.name + '.comments.csv'] = Exporter::Comments.new(cart).to_csv
      attachments['Communicart' + cart.name + '.approvals.csv'] = Exporter::Approvals.new(cart).to_csv
    end
  end

  # for easier stubbing in tests
  def from_email
    ENV['NOTIFICATION_FROM_EMAIL'] || 'sender@some-dot_gov.gov'
  end

  def send_cart_email(email, cart)
    @cart = cart.decorate
    @prefix_template = @cart.prefix_template_name

    set_attachments(cart)

    approval_format = Settings.email_title_for_approval_request_format
    mail(
      to: email,
      subject: approval_format % [ cart.requester.full_name,cart.external_id],
      from: from_email
    )
  end
end
