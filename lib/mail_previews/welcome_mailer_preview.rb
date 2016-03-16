class WelcomeMailerPreview < ActionMailer::Preview
  include MailerPreviewHelpers

  def welcome_notification
    WelcomeMailer.welcome_notification(user)
  end
end
