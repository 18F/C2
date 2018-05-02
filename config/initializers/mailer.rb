if Rails.env.production?
  protocol = "https"
end

C2::Application.config.action_mailer.default_url_options ||= {
  host: AppParamCredentials.default_url_host,
  protocol: protocol || "http"
}

# indicate that this is not a real request in the email subjects,
# if we are running in non-production env.
# NOTE that staging uses Rails.env.production, so cannot rely on that config.
unless ENV["DISABLE_SANDBOX_WARNING"] == "true"
  class PrefixEmailSubject
    def self.delivering_email(mail)
      mail.subject = "[TEST] " + mail.subject
    end
  end

  ActionMailer::Base.register_interceptor(PrefixEmailSubject)
end

# Register custom SES delivery method
ActionMailer::Base.add_delivery_method :ses_mail_delivery, ::SesMailDelivery
