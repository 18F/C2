describe AttachmentMailer do
  include MailerSpecHelper

  describe "#new_attachment_notification" do
    let(:mail) { AttachmentMailer.new_attachment_notification(requester.email_address, proposal, attachment) }

    it_behaves_like "a proposal email"

    it "includes the name of the user who added the attachment" do
      expect(mail.body.encoded).to include(attachment.user.full_name)
    end

    def attachment
      @attachment ||= create(:attachment)
    end

    def proposal
      @proposal ||= create(:proposal, :with_parallel_approvers)
    end

    def requester
      proposal.requester
    end
  end
end
