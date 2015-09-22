class FeedbackMailer < ApplicationMailer
  def feedback(sending_user, form_values)
    form_strings = form_values.map { |key, val| "#{key}: #{val}" }
    message = form_strings.join("\n")
    from = sending_user.try(:email_address) || form_values[:email] || self.default_sender_email
    mail(
      to: self.class.support_email,
      subject: '[C2] Feedback submission',
      from: from,
      cc: from,
      body: message
    )
  end

  def self.support_email
    ENV['SUPPORT_EMAIL'] || 'tickets@18f.uservoice.com' # not sensitive, so hard coding
  end
end
