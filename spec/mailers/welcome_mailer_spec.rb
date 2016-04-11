describe WelcomeMailer do
  include Rails.application.routes.url_helpers

  describe "#welcome_notification" do
    it "includes the welcome text" do
      user = create(:user)

      mail = WelcomeMailer.welcome_notification(user)

      linebreaker = "=\r\n"
      body_no_newlines = mail.body.encoded.gsub(linebreaker, "")

      expect(body_no_newlines).to include(
        I18n.t("mailer.welcome_mailer.welcome_notification.header")
      )
      expect(body_no_newlines).to include(
        I18n.t("mailer.welcome_mailer.welcome_notification.para1")
      )
      expect(body_no_newlines).to include(
        I18n.t("mailer.welcome_mailer.welcome_notification.para2_html", help_url: help_url(''))
      )
      expect(body_no_newlines).to include(
        I18n.t("mailer.welcome_mailer.welcome_notification.para3_html", feedback_url: feedback_url)
      )
      expect(body_no_newlines).to include(
        I18n.t("mailer.welcome_mailer.welcome_notification.signature")
      )
    end
  end
end
