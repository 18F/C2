class WelcomeMailer < ApplicationMailer
  layout "basic"

  def welcome_notification(user)
    to_email = user.email_address

    mail(
      to: email_with_name(user.email_address, user.full_name),
      subject: "Welcome to C2!",
      from: default_sender_email
    )
  end
end
