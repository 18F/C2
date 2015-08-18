class FeedbackMailer < ApplicationMailer
  def feedback(sending_user, form_values)
    form_strings = form_values.map { |pair| "#{pair[0]}: #{pair[1]}" }
    message = form_strings.join("\n")
    mail(
      to: self.class.support_email,
      subject: 'Feedback submission',
      from: self.default_sender_email,
      body: message,
      cc: sending_user.try(:email_address)
    )
  end

  def self.support_email
    ENV['SUPPORT_EMAIL'] || 'gatewaycommunicator@gsa.gov' # not sensitive, so hard coding
  end
end
