describe CommentMailer do
  include MailerSpecHelper
  include EnvVarSpecHelper

  describe "#comment_added_email" do
    it_behaves_like "a proposal email" do
      let(:proposal) { create(:proposal) }
      let(:comment) { create(:comment, proposal: proposal) }
      let(:mail) { CommentMailer.comment_added_email(comment, "test@example.com") }
    end

    it "sends to the receiver email" do
      comment = create(:comment)

      mail = CommentMailer.comment_added_email(comment, email_address)

      expect(mail.to).to eq([email_address])
    end

    it "sets the sender name as the commenter full name" do
      comment = create(:comment)

      mail = CommentMailer.comment_added_email(comment, email_address)

      expect(sender_names(mail)).to eq([comment.user.full_name])
    end

    it "includes the commenter full name in the email body" do
      comment = create(:comment)

      mail = CommentMailer.comment_added_email(comment, email_address)

      expect(mail.body.encoded).to include(I18n.t(
        "mailer.comment_mailer.comment_added_email.body",
        full_name: comment.user.full_name,
        public_id: comment.proposal.public_id,
        name: comment.proposal.name
      ))
    end
  end

  def email_address
    "commenter@example.com"
  end
end
