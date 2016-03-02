class WelcomeMailerPreview < ActionMailer::Preview
  def welcome_notification
    WelcomeMailer.welcome_notification(user)
  end

  private

  def user
    User.for_email("test@example.com")
  end
end
