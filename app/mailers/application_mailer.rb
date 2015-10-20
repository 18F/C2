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
    email_with_name(ENV['NOTIFICATION_REPLY_TO'] || 'noreplyto@some.gov', 'C2')
  end

  def sender_email
    email_with_name(ENV['NOTIFICATION_FROM_EMAIL'] || 'noreply@some.gov', 'C2')
  end

  def resend_to_email
    email_with_name(ENV['NOTIFICATION_FALLBACK_EMAIL'] || 'communicart.sender@gsa.gov', 'C2')
  end

  def default_sender_email
    sender_email
  end

  def user_email_with_name(user)
    email_with_name(sender_email, user.full_name)
  end
end
