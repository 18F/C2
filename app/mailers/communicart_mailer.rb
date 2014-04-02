class CommunicartMailer < ActionMailer::Base
  default from: ENV['GMAIL_USERNAME']

  def cart_notification_email(user)
    @url = ENV['NOTIFICATION_URL']
    mail(to: ENV['NOTIFICATION_TO_EMAIL'], subject: "You have received a Communicart notification")
  end
end