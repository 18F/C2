class WelcomeMailer < ApplicationMailer
  layout "basic"

  def welcome_notification(user)
    mail(
      to: email_to_user(user),
      subject: "Welcome to C2!",
      from: default_sender_email
    )
  end
end
