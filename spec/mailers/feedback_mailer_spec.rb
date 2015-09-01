describe FeedbackMailer do
  describe 'feedback' do
    it "sends from the submitter" do
      user = FactoryGirl.create(:user)
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

    with_env_var('SUPPORT_EMAIL', 'support@some-dot-gov.gov') do
      it "sends to the support email" do
        mail = FeedbackMailer.feedback(nil, {})
        expect(mail.to).to eq(['support@some-dot-gov.gov'])
      end
    end
  end
end
