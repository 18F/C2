class WelcomeMailer < ApplicationMailer
  def welcome_notification(user)
    @user = user

    mail(
      to: user.email_address,
      subject: "Welcome to C2!",
      from: default_sender_email
    )
  end
end
