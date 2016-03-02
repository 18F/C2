class WelcomeMailer < ApplicationMailer
  def welcome_notification(user)
    mail(
      to: email_with_name(user.email_address, user.full_name),
      subject: "Welcome to C2!",
      from: default_sender_email
    )
  end
end
