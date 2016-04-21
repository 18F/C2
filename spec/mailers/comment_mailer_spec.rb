describe CommentMailer do
  include MailerSpecHelper
  include EnvVarSpecHelper

  let(:user) { create(:user) }

  describe "#comment_added_notification" do
    it_behaves_like "a proposal email" do
      let(:proposal) { create(:proposal) }
      let(:comment) { create(:comment, proposal: proposal) }
      let(:mail) { CommentMailer.comment_added_notification(comment, user) }
    end

    it "sends to the receiver email" do
      comment = create(:comment)

      mail = CommentMailer.comment_added_notification(comment, user)

      expect(mail.to).to eq([user.email_address])
    end

    it "sets the sender name as the commenter full name" do
      comment = create(:comment)

      mail = CommentMailer.comment_added_notification(comment, user)

      expect(sender_names(mail)).to eq([comment.user.full_name])
    end

    it "sets the sender full name if passed just an address" do
      comment = create(:comment)

      mail = CommentMailer.comment_added_notification(comment, user.email_address)

      expect(sender_names(mail)).to eq([comment.user.full_name])
    end

    it "includes the commenter full name in the email body" do
      comment = create(:comment)

      mail = CommentMailer.comment_added_notification(comment, user)

      expect(mail.body.encoded).to include(I18n.t(
        "mailer.comment_mailer.comment_added_notification.header",
        user_name: comment.user.full_name,
        proposal_name: comment.proposal.name
      ))
    end
  end
end
