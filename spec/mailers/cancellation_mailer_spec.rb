describe CancellationMailer do
  describe ".cancellation_email" do
    it "includes the cancellation reason" do
      user = create(:user)
      proposal = create(:proposal, requester: user)
      reason = "cancellation reason"

      mail = CancellationMailer.cancellation_email(user.email_address, proposal, reason)

      expect(mail.body.encoded).to include(
        "has been cancelled with given reason '#{reason}'."
      )
    end
  end

  describe ".proposal_fiscal_cancellation" do
    it "sends cancellation email for fiscal-year cleanup" do
      proposal = create(:proposal)
      mail = CancellationMailer.proposal_fiscal_cancellation(proposal)
      expect(mail.to).to eq([proposal.requester.email_address])
    end
  end
end
