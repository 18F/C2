class CommunicartMailer < ActionMailer::Base
  layout 'communicart_base'
  helper_method :set_attachments


  def set_attachments(cart)
    if cart.all_approvals_received?
      attachments['Communicart' + cart.name + '.details.csv'] = Exporter::Items.new(cart).to_csv
      attachments['Communicart' + cart.name + '.comments.csv'] = Exporter::Comments.new(cart).to_csv
      attachments['Communicart' + cart.name + '.approvals.csv'] = Exporter::Approvals.new(cart).to_csv
    end
  end


  def cart_notification_email(email, approval)
    cart = approval.cart
    @url = ENV['NOTIFICATION_URL']
    @cart = cart.decorate
    @approval = approval
    @token = ApiToken.where(user_id: @approval.user_id).where(cart_id: @cart.id).last
    @prefix_template = @cart.prefix_template_name

    set_attachments(cart)

    approval_format = Settings.email_title_for_approval_request_format
    mail(
         to: email,
         subject: approval_format % [ cart.requester.full_name,cart.external_id],
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

  def cart_observer_email(email, cart)
    @url = ENV['NOTIFICATION_URL']
    @cart = cart.decorate
    @prefix_template = @cart.prefix_template_name

    set_attachments(cart)

    approval_format = Settings.email_title_for_approval_request_format
    mail(
         to: email,
         subject: approval_format % [ cart.requester.full_name,cart.external_id],
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

  def approval_reply_received_email(approval)
    cart = approval.cart
    @approval = approval
    @cart = cart.decorate
    to_address = cart.requester.email_address
    #TODO: Handle carts without approval groups (only emails passed)
    #TODO: Add a specific 'rejection' text block for the requester

    set_attachments(cart)

    @url = ENV['NOTIFICATION_URL']
    mail(
         to: to_address,
         subject: "User #{approval.user.email_address} has #{approval.status} cart ##{cart.external_id}",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

  def rejection_update_email(params, cart)
    # TODO: Fill out the content of this email to the approvers
  end

  def comment_added_email(comment, to_email)
    @comment_text = comment.comment_text
    @cart_item = comment.commentable

    mail(
         to: to_email,
         subject: "A comment has been added to cart item '#{@cart_item.description}'",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

end
