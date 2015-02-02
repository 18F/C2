class CommunicartMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  layout 'communicart_base'
  add_template_helper CommunicartMailerHelper
  add_template_helper TimeHelper


  def cart_notification_email(to_email, approval)
    @approval = approval
    from_email = user_email(approval.cart.requester)
    send_cart_email(from_email, to_email, approval.cart)
  end

  def cart_observer_email(to_email, cart)
    # TODO have the from_email be whomever triggered this notification
    send_cart_email(sender, to_email, cart)
  end

  def sent_confirmation_email(cart)
    @cart = cart.decorate
    to_address = cart.requester.email_address

    mail(
         to: to_address,
         subject: "Your request for Proposal ##{cart.id} has been sent successfully.",
         from: from_email
         )
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
         from: user_email(approval.user)
         )
  end

  def comment_added_email(comment, to_email)
    @comment_text = comment.comment_text
    @cart_item = comment.commentable

    mail(
         to: to_email,
         subject: "A comment has been added to cart item '#{@cart_item.description}'",
         from: user_email(comment.user)
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
  def sender
    ENV['NOTIFICATION_FROM_EMAIL'] || 'user_email@some-dot_gov.gov'
  end

  def user_email(user)
    # http://stackoverflow.com/a/8106387/358804
    address = Mail::Address.new(sender)
    address.display_name = user.full_name
    address.format
  end

  def subject(cart)
    approval_format = Settings.email_title_for_approval_request_format
    approval_format % [cart.requester.full_name, cart.public_identifier]
  end

  def send_cart_email(from_email, to_email, cart)
    @cart = cart.decorate
    @prefix_template = @cart.prefix_template_name

    set_attachments(cart)

    mail(
      to: to_email,
      subject: subject(cart),
      from: from_email
    )
  end
end
