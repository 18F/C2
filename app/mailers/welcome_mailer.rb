class WelcomeMailer < ApplicationMailer
  def welcome_notification(user)
    @user = user

    mail(
      to: email_to_user(user),
      subject: "Welcome to C2!",
      from: default_sender_email
    )
  end
end
