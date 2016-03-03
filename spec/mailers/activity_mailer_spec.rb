describe ActivityMailer do
  include MailerSpecHelper

  describe "#activity_notification" do
    it "contains the activity string" do
      proposal = create(:proposal)
      user = create(:user)
      activity = "something happened!"

      mail = ActivityMailer.activity_notification(user, proposal, activity)

      expect(mail.body.encoded).to include(activity)
    end

    it "sends to the user" do
      proposal = create(:proposal)
      user = create(:user)
      activity = "something happened!"

      mail = ActivityMailer.activity_notification(user, proposal, activity)

      expect(mail.to).to eq([user.email_address])
    end
  end
end
