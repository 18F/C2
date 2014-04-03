class CommunicartMailer < ActionMailer::Base
  default from: ENV['NOTIFICATION_FROM_EMAIL']

  def cart_notification_email(analysis)
    binding.pry
    @url = ENV['NOTIFICATION_URL']
    mail(to: analysis['attention'], subject: "You have received a Communicart notification")
  end
end
