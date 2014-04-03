class CommunicartMailer < ActionMailer::Base
  default from: ENV['NOTIFICATION_FROM_EMAIL']

  def cart_notification_email(user)
    @url = ENV['NOTIFICATION_URL']
    mail(to: ENV['NOTIFICATION_TO_EMAIL'], subject: "You have received a Communicart notification")
  end
end