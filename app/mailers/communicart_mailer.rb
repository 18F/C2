class CommunicartMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  layout 'communicart_base'
  add_template_helper CommunicartMailerHelper
  add_template_helper TimeHelper
  add_template_helper ClientHelper


  def cart_notification_email(to_email, approval)
    @approval = approval
    from_email = user_email(approval.cart.requester)
    send_cart_email(from_email, to_email, approval.cart)
  end

  def cart_observer_email(to_email, cart)
    # TODO have the from_email be whomever triggered this notification
    send_cart_email(sender, to_email, cart)
  end

  def proposal_created_confirmation(cart)
    @cart = cart.decorate
    to_address = cart.requester.email_address
    from_email = user_email(cart.requester)

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
         subject: "User #{approval.user.email_address} has #{approval.status} cart ##{cart.proposal.public_identifier}",
         from: user_email(approval.user)
         )
  end

  def comment_added_email(comment, to_email)
    @comment = comment

    mail(
         to: to_email,
         subject: "A comment has been added to '#{comment.proposal.name}'",
         from: user_email(comment.user)
         )
  end


  private

  def set_attachments(cart)
    if cart.all_approvals_received?
      attachments['Communicart' + cart.proposal.public_identifier.to_s + '.comments.csv'] = Exporter::Comments.new(cart).to_csv
      attachments['Communicart' + cart.proposal.public_identifier.to_s + '.approvals.csv'] = Exporter::Approvals.new(cart).to_csv
    end
  end

  # for easier stubbing in tests
  def sender
    ENV['NOTIFICATION_FROM_EMAIL'] || 'noreply@some.gov'
  end

  def user_email(user)
    # http://stackoverflow.com/a/8106387/358804
    address = Mail::Address.new(sender)
    address.display_name = user.full_name
    address.format
  end

  def subject(cart)
    "Communicart Approval Request from #{cart.requester.full_name}: Please review Cart ##{cart.proposal.public_identifier}"
  end

  def send_cart_email(from_email, to_email, cart)
    @cart = cart.decorate
    # only used by navigator. @todo: remove
    @prefix_template = @cart.prefix_template_name

    set_attachments(cart)

    mail(
      to: to_email,
      subject: subject(cart),
      from: from_email
    )
  end
end
