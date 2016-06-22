describe AttachmentMailer do
  include MailerSpecHelper

  before(:all) { ENV["DISABLE_EMAIL"] = nil }
  after(:all)  { ENV["DISABLE_EMAIL"] = "Yes" }

  describe "#new_attachment_notification" do
    let(:mail) { AttachmentMailer.new_attachment_notification(requester, proposal, attachment) }

    it_behaves_like "a proposal email"

    it "includes the name of the user who added the attachment" do
      expect(mail.body.encoded).to include(attachment.user.full_name)
    end

    def attachment
      @attachment ||= create(:attachment)
    end

    def proposal
      @proposal ||= create(:proposal)
    end

    def requester
      proposal.requester
    end
  end
end
