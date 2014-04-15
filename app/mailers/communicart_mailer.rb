  class CommunicartMailer < ActionMailer::Base
  default from: ENV['NOTIFICATION_FROM_EMAIL']

  def cart_notification_email(email,analysis)
    @json_post = analysis
    @url = ENV['NOTIFICATION_URL']
    mail(to: email, subject: "Please approve Cart Number: "+analysis["cartNumber"])
  end

  def approval_reply_received_email(analysis, report)
    to_address = ENV['NOTIFICATION_TO_ADDRESS'] ? ENV['NOTIFICATION_TO_ADDRESS'] : 'read.robert@gmail.com' #TODO: Remove this default address
    @approval = analysis["approve"] == "APPROVE" ? "approved" : "disapproved"
    @approval_reply = analysis
    @report = report

    @url = ENV['NOTIFICATION_URL']
    mail(to: to_address, subject: "User "+analysis["fromAddress"]+" has "+@approval+" cart # "+analysis["cartNumber"])
  end
end

