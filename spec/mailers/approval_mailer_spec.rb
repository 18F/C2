describe ApprovalMailer do
  include MailerSpecHelper

  describe "#approval_reply_received_email" do
    let(:mail) { ApprovalMailer.approval_reply_received_email(approval) }

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

    context "comments" do
      it "renders comments when present" do
        create(:comment, comment_text: "My added comment", proposal: proposal)
        expect(mail.body.encoded).to include("Comments")
      end

      it "does not render empty comments" do
        expect(mail.body.encoded).to_not include("Comments")
      end
    end

    context "completed message" do
      it "displays when all requests have been approved" do
        final_approval = proposal.individual_steps.last
        final_approval.proposal   # create a dirty cache
        final_approval.approve!
        mail = ApprovalMailer.approval_reply_received_email(final_approval)
        expect(mail.body.encoded).to include(I18n.t("mailer.approval_reply_received_email.approved"))
      end

      it "displays purchase-step-specific language when final step is approved" do
        proposal = create(:proposal, :with_approval_and_purchase, client_slug: "test")
        proposal.individual_steps.first.approve!
        final_step = proposal.individual_steps.last
        final_step.proposal   # create a dirty cache
        final_step.approve!
        mail = ApprovalMailer.approval_reply_received_email(final_step)
        expect(mail.body.encoded).to include(I18n.t("mailer.approval_reply_received_email.purchased"))
      end

      it "does not display when requests are still pending" do
        mail = ApprovalMailer.approval_reply_received_email(approval)

        expect(mail.body.encoded).not_to include(I18n.t("mailer.approval_reply_received_email.approved"))
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
end
