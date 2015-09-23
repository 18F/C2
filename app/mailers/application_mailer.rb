class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  default reply_to: proc { reply_to_email }

  protected

  def email_with_name(email, name)
    # http://stackoverflow.com/a/8106387/358804
    address = Mail::Address.new(email)
    address.display_name = name
    address.format
  end

  def reply_to_email
    ENV['NOTIFICATION_REPLY_TO'] || 'noreplyto@some.gov'
  end

  def sender_email
    ENV['NOTIFICATION_FROM_EMAIL'] || 'noreply@some.gov'
  end

  def default_sender_email
    email_with_name(sender_email, "Communicart")
  end

  def user_email_with_name(user)
    email_with_name(sender_email, user.full_name)
  end
end
