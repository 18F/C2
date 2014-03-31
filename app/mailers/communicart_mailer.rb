class CommunicartMailer < ActionMailer::Base
  default from: "reply@communicart-stub.com"

  def cart_notification_email(user)
    @url = 'localhost:3000/'
    mail(to: 'george.jetson@spacelysprockets.com', subject: 'You have received a Communicart notification...')
  end
end