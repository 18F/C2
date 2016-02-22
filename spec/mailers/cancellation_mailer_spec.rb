describe CancellationMailer do
  describe "#cancellation_notification" do
    it "includes the cancellation reason" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      reason = "cancellation reason"

      mail = CancellationMailer.cancellation_notification(user.email_address, proposal, reason)

      expect(mail.body.encoded).to include(
        I18n.t("mailer.cancellation_mailer.cancellation_notification.reason", reason: reason)
      )
    end
  end

  describe "#cancellation_confirmation" do
    it "includes the cancellation reason" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      reason = "cancellation reason"

      mail = CancellationMailer.cancellation_confirmation(proposal, reason)

      expect(mail.body.encoded).to include(
        I18n.t("mailer.cancellation_mailer.cancellation_confirmation.reason", reason: reason)
      )
    end
  end

  describe "#fiscal_cancellation" do
    it "sends cancellation email for fiscal-year cleanup" do
      proposal = create(:proposal)

      mail = CancellationMailer.fiscal_cancellation_notification(proposal)

      expect(mail.to).to eq([proposal.requester.email_address])
    end
  end
end
