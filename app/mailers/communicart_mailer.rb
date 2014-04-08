  class CommunicartMailer < ActionMailer::Base
  default from: ENV['NOTIFICATION_FROM_EMAIL']

  def cart_notification_email(analysis)
    @json_post = analysis
    @url = ENV['NOTIFICATION_URL']
    if !analysis['email'].blank?
# This case assumes there is a single email approval
      mail(to: analysis['email'], subject: "Please approve Cart Number: "+analysis["cartNumber"])
    elsif !analysis['approvalGroup'].blank?
      logger.debug "Not Implemented -- got an approvalGroup but that is not mapped to emails yet."
    else
      logger.debug "ApprovalGroup and email both empty, can't process this SendCart Request!"
# Here we want to loock up the approvalGroup from the model somehow, that is for Raphy, then we will
# send to every member of the approval Group!
    end
  end

  def approval_reply_received_email(analysis)
    to_address = ENV['NOTIFICATION_TO_ADDRESS'] ? ENV['NOTIFICATION_TO_ADDRESS'] : 'read.robert@gmail.com'
    @approval = analysis["approve"] == "APPROVE" ? "approved" : "disapproved"
    @approval_reply = analysis
    @url = ENV['NOTIFICATION_URL']
    mail(to: to_address, subject: "User "+analysis["fromAddress"]+" has "+@approval+" cart # "+analysis["cartNumber"])
  end
end

