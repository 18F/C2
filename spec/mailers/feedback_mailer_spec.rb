describe FeedbackMailer do
  describe 'feedback' do
    it "sends from the submitter" do
      user = create(:user)
      mail = FeedbackMailer.feedback(user, {})
      expect(mail.from).to eq([user.email_address])
    end

    it "doesn't require a user to be passed in" do
      expect {
        FeedbackMailer.feedback(nil, {})
      }.to_not raise_error
    end

    it "includes the form values" do
      mail = FeedbackMailer.feedback(nil, foo: 'bar')
      expect(mail.body.encoded).to include('foo')
      expect(mail.body.encoded).to include('bar')
    end

    it "uses unique message IDs for each send" do
      mail1 = FeedbackMailer.feedback(nil, {})
      mail2 = FeedbackMailer.feedback(nil, {})
      expect(mail1.header['In-Reply-To'].to_s).to_not eq(mail2.header['In-Reply-To'].to_s)
    end

    with_env_var('SUPPORT_EMAIL', 'support@example.com') do
      it "sends to the support email" do
        mail = FeedbackMailer.feedback(nil, {})
        expect(mail.to).to eq(['support@example.com'])
      end
    end

    it "uses sender as reply-to address" do
      user = create(:user)
      mail = FeedbackMailer.feedback(user, {})
      expect(mail.reply_to).to eq([user.email_address])
    end
  end
end
