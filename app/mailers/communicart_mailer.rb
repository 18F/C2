  class CommunicartMailer < ActionMailer::Base
  layout 'communicart_base'

  def cart_notification_email(email, cart, approval)
    @url = ENV['NOTIFICATION_URL']
    @cart = cart.decorate
    @approval = approval
    @token = ApiToken.where(user_id: @approval.user_id).where(cart_id: @cart.id).last

    if cart.all_approvals_received?
      attachments['Communicart' + cart.name + '.details.csv'] = cart.create_items_csv
      attachments['Communicart' + cart.name + '.comments.csv'] = cart.create_comments_csv
      attachments['Communicart' + cart.name + '.approvals.csv'] = cart.create_approvals_csv
    end

    mail(
         to: email,
         subject: "Communicart Approval Request from #{cart.requester.full_name}: Please review Cart ##{cart.external_id}",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

  def approval_reply_received_email(analysis, cart)
    @approval = analysis["approve"] == "APPROVE" ? "approved" : "rejected"
    @approval_reply = analysis
    @cart = cart.decorate

    to_address = cart.requester.email_address
    #TODO: Handle carts without approval groups (only emails passed)
    #TODO: Add a specific 'rejection' text block for the requester

    if cart.all_approvals_received?
      attachments['Communicart' + cart.name + '.details.csv'] = cart.create_items_csv
      attachments['Communicart' + cart.name + '.comments.csv'] = cart.create_comments_csv
      attachments['Communicart' + cart.name + '.approvals.csv'] = cart.create_approvals_csv
    end

    @url = ENV['NOTIFICATION_URL']
    mail(
         to: to_address,
         subject: "User #{analysis['fromAddress']} has #{@approval} cart ##{analysis['cartNumber']}",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

  def rejection_update_email(params, cart)
    # CURRENT TODO: Fill out the content of this email to the approvers

  end

end

