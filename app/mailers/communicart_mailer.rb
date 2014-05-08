  class CommunicartMailer < ActionMailer::Base
  layout 'communicart_base'

  def cart_notification_email(email, analysis, cart)
    @json_post = analysis
    @url = ENV['NOTIFICATION_URL']
    @cart = cart.decorate

    attachments['Communicart' + cart.name + '.details.csv'] = cart.create_items_csv
    attachments['Communicart' + cart.name + '.comments.csv'] = cart.create_comments_csv

    mail(
         to: email,
         subject: "Please approve Cart Number: #{analysis['cartNumber']}",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

  def approval_reply_received_email(analysis, report)
    @approval = analysis["approve"] == "APPROVE" ? "approved" : "reject"
    @approval_reply = analysis
    @report = report

    @cart = report.cart.decorate
    to_address = @cart.requester.email_address
    #TODO: Handle carts without approval groups (only emails passed)
    #TODO: Add a specific 'rejection' text block for the requester

    attachments['Communicart' + @cart.name + '.details.csv'] = @cart.create_items_csv
    attachments['Communicart' + @cart.name + '.comments.csv'] = @cart.create_comments_csv

    if @cart.all_approvals_received?
      attachments['Communicart' + @cart.name + '.approvals.csv'] = @cart.create_approvals_csv
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

