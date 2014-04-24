  class CommunicartMailer < ActionMailer::Base
  default from: ENV['NOTIFICATION_FROM_EMAIL']
  layout 'communicart_base'

  def cart_notification_email(email,analysis)
    @json_post = analysis
    @url = ENV['NOTIFICATION_URL']
    mail(
         to: email,
         subject: "Please approve Cart Number: #{analysis['cartNumber']}"
         )
  end

  def approval_reply_received_email(analysis, report)
    @approval = analysis["approve"] == "APPROVE" ? "approved" : "disapproved"
    @approval_reply = analysis
    @report = report
    @cart = report.cart.decorate
    to_address = @cart.approval_group.requester.email_address

    @url = ENV['NOTIFICATION_URL']
    mail(
         to: to_address,
         subject: "User #{analysis['fromAddress']} has #{@approval} cart ##{analysis['cartNumber']}"
         )
  end
end

