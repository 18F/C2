describe CancelationMailer do
  describe "#cancelation_notification" do
    let(:proposal) { create(:proposal) }
    let(:user) { create(:user) }
    let(:mail) { CancelationMailer.cancelation_notification(
      recipient_email: user.email_address,
      canceler: user,
      proposal: proposal
    ) }

    it_behaves_like "a proposal email"

    it "includes the cancelation reason" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      reason = "cancelation reason"

      mail = CancelationMailer.cancelation_notification(
        recipient_email: user.email_address,
        canceler: user,
        proposal: proposal,
        reason: reason
      )

      expect(mail.body.encoded).to include(
        I18n.t("mailer.cancelation_mailer.cancelation_notification.reason", reason: reason)
      )
    end
  end

  describe "#cancelation_confirmation" do
    let(:proposal) { create(:proposal) }
    let(:user) { create(:user) }
    let(:mail) { CancelationMailer.cancelation_confirmation(
      canceler: user,
      proposal: proposal
    ) }

    it_behaves_like "a proposal email"

    it "includes the cancelation reason" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      reason = "cancelation reason"

      mail = CancelationMailer.cancelation_confirmation(
        canceler: user,
        proposal: proposal,
        reason: reason
      )

      expect(mail.body.encoded).to include(
        I18n.t("mailer.cancelation_mailer.cancelation_confirmation.reason", reason: reason)
      )
    end
  end

  describe "#fiscal_cancelation" do
    it "sends cancelation email for fiscal-year cleanup" do
      proposal = create(:proposal)

      mail = CancelationMailer.fiscal_cancelation_notification(proposal)

      expect(mail.to).to eq([proposal.requester.email_address])
    end
  end
end
