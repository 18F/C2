class Mailer < ApplicationMailer
  def resend(msg)
    @_message = Mail.new(msg)
    # we want to preserve the From name but not the email address, since gsa.gov
    # will block any @gsa.gov From address. We still use it intact in reply-to.
    from_raw = @_message.header["From"].value

    mail(
      subject: @_message.subject,
      to: resend_to_email,
      from: email_with_name(sender_email, Mail::Address.new(from_raw).display_name),
      reply_to: from_raw,
      "X-C2-Original-To" => @_message.header["To"].value,
      "X-C2-Original-From" => from_raw
    ) {} # no-op block so template error is avoided (body already in @_message)
  end
end
