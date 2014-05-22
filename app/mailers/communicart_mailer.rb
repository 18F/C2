  class CommunicartMailer < ActionMailer::Base
  # default from: ENV['NOTIFICATION_FROM_EMAIL']
  layout 'communicart_base'

  def cart_notification_email(email,analysis,cart)
    # Note:  This is ALMOST removable -- We should refactor this,
    # which opens the door to a major refactoring of cart_notification_email.html.erb and
    # approval_reply_received_email.html.erb.
    @json_post = analysis
    @url = ENV['NOTIFICATION_URL']
    @cart = cart

    attachments['Communicart'+cart.name+'.details.csv'] = cart.create_items_csv
    attachments['Communicart'+cart.name+'.comments.csv'] = cart.create_comments_csv

    mail(
         to: email,
         subject: "Please approve Cart Number: #{analysis['cartNumber']}",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end

  def approval_reply_received_email(analysis, report)
    @approval = analysis["approve"] == "APPROVE" ? "approved" : "disapproved"
    @approval_reply = analysis
    @report = report
    @cart = report.cart.decorate
    to_address = @cart.approval_group.requester.email_address

    attachments['Communicart'+@cart.name+'.details.csv'] = @cart.create_items_csv
    attachments['Communicart'+@cart.name+'.comments.csv'] = @cart.create_comments_csv

    if @cart.all_approvals_received?
      attachments['Communicart'+@cart.name+'.approvals.csv'] = @cart.create_approvals_csv      
    end

    @url = ENV['NOTIFICATION_URL']
    mail(
         to: to_address,
         subject: "User #{analysis['fromAddress']} has #{@approval} cart ##{analysis['cartNumber']}",
         from: ENV['NOTIFICATION_FROM_EMAIL']
         )
  end
end

