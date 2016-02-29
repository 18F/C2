describe StepMailer do
  include MailerSpecHelper

  describe "#step_user_reply" do
    let(:mail) { StepMailer.step_reply_received(approval) }

    before do
      approval.approve!
    end

    it_behaves_like "a proposal email"

    it "renders the receiver email" do
      expect(mail.to).to eq([proposal.requester.email_address])
    end

    it "sets the sender name" do
      expect(sender_names(mail)).to eq([approver.full_name])
    end


    context "completed message" do
      it "displays when all requests have been approved" do
        final_approval = proposal.individual_steps.last
        final_approval.proposal   # create a dirty cache
        final_approval.approve!
        mail = StepMailer.step_reply_received(final_approval)
        expect(mail.body.encoded).to include(I18n.t("mailer.step_mailer.step_reply_received.approved"))
      end

      it "displays purchase-step-specific language when final step is approved" do
        proposal = create(:proposal, :with_approval_and_purchase, client_slug: "test")
        proposal.individual_steps.first.approve!
        final_step = proposal.individual_steps.last
        final_step.proposal   # create a dirty cache
        final_step.approve!
        mail = StepMailer.step_reply_received(final_step)
        expect(mail.body.encoded).to include(I18n.t("mailer.step_mailer.step_reply_received.purchased"))
      end

      it "does not display when requests are still pending" do
        mail = StepMailer.step_reply_received(approval)

        expect(mail.body.encoded).not_to include(I18n.t("mailer.step_mailer.step_reply_received.approved"))
      end
    end
  end

  describe "#step_reply_received" do
    let(:mail) { StepMailer.step_user_removed(approver.email_address, proposal) }

    before do
      approval.approve!
    end

    it_behaves_like "a proposal email"

    it "tells the user thet have been removed" do
      expect(mail.body.encoded).to include(
        I18n.t("mailer.step_mailer.step_user_removed.header")
      )
    end
  end

  private

  def proposal
    @proposal ||= create(:proposal, :with_serial_approvers)
  end

  def approval
    proposal.individual_steps.first
  end

  def approver
    approval.user
  end
end
