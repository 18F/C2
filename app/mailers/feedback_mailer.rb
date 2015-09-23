class FeedbackMailer < ApplicationMailer
  include ConversationThreading

  def feedback(sending_user, form_values)
    form_strings = form_values.map { |key, val| "#{key}: #{val}" }
    message = form_strings.join("\n")
    from = sending_user.try(:email_address) || form_values[:email] || self.default_sender_email

    # ensure each new feedback email is in its own thread
    self.set_thread_id(SecureRandom.hex)

    mail(
      to: self.class.support_email,
      subject: 'Feedback submission',
      from: from,
      cc: from,
      body: message
    )
  end

  def self.support_email
    ENV['SUPPORT_EMAIL'] || 'gatewaycommunicator@gsa.gov' # not sensitive, so hard coding
  end
end
