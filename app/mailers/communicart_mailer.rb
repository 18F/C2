class CommunicartMailer < ActionMailer::Base
  default from: ENV['NOTIFICATION_FROM_EMAIL']

  def cart_notification_email(analysis)
    @url = ENV['NOTIFICATION_URL']
    mail(to: analysis['attention'], subject: "You have received a Communicart notification")
  end

  def approval_reply_received_email(analysis)
    binding.pry
    to_address = ENV['NOTIFICATION_TO_ADDRESS'] ? ENV['NOTIFICATION_TO_ADDRESS'] : 'read.robert@gmail.com'
    @url = ENV['NOTIFICATION_URL']
    mail(to: to_address, subject: "You have received a Communicart notification")
  end
end

