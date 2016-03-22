class FeedbackMailer < ApplicationMailer
  skip_before_action :add_logo

  def feedback(sending_user, form_values)
    from = sending_user.try(:email_address) || form_values[:email] || default_sender_email

    # ensure each new feedback email is in its own thread
    self.thread_id = SecureRandom.hex

    mail(
      to: self.class.support_email,
      subject: "[C2] Feedback submission",
      from: from,
      cc: from,
      reply_to: from,
      body: body_for(form_values)
    )
  end

  def self.support_email
    ENV["SUPPORT_EMAIL"] || "tickets@18f.uservoice.com" # not sensitive, so hard coding
  end

  protected

  def body_for(form_values)
    form_strings = form_values.map { |key, val| "#{key}: #{val}" }
    form_strings.join("\n")
  end
end
