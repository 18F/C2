  class CommunicartMailer < ActionMailer::Base
  layout 'communicart_base'

  def cart_notification_email(email, analysis, cart)
    @json_post = analysis
    @url = ENV['NOTIFICATION_URL']
    @cart = cart.decorate

    if cart.all_approvals_received?
      attachments['Communicart' + cart.name + '.details.csv'] = cart.create_items_csv
      attachments['Communicart' + cart.name + '.comments.csv'] = cart.create_comments_csv
      attachments['Communicart' + cart.name + '.approvals.csv'] = cart.create_approvals_csv
    end

    mail(
         to: email,
         subject: "Please approve Cart Number: #{analysis['cartNumber']}",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

  def approval_reply_received_email(analysis, cart)
    @approval = analysis["approve"] == "APPROVE" ? "approved" : "reject"
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

  def unfound_approval_group_email(analysis)
    puts "to email = "+ENV['ADMINISTRATIVE_ERROR_EMAIL']
    puts "to email = "+ENV['NOTIFICATION_FROM_EMAIL']
    mail(
         to: ENV['ADMINISTRATIVE_ERROR_EMAIL'],
      #   subject: "Unknown user for cart initiated cart #{analysis['cartNumber']}, but approval group #{analysis['approvalGroup']} was not found: ",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         ).deliver
  end

end

