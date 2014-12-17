describe ParallelDispatcher do
  let(:cart) { FactoryGirl.create(:cart_with_approvals) }
  let(:dispatcher) { ParallelDispatcher.new }

  describe '#deliver_new_cart_emails' do
    it "sends emails to all approvers" do
      dispatcher.deliver_new_cart_emails(cart)
      expect(email_recipients).to eq([
        'approver1@some-dot-gov.gov',
        'approver2@some-dot-gov.gov'
      ])
    end

    it 'creates a new token for each approver' do
      expect(ApiToken).to receive(:create!).exactly(2).times
      expect(dispatcher).to receive(:send_notification_email).twice
      dispatcher.deliver_new_cart_emails(cart)
    end

    it 'sends a cart notification email to observers' do
      cart.approvals << FactoryGirl.create(:approval_with_user, role: 'observer')
      expect(CommunicartMailer).to receive_message_chain(:cart_observer_email, :deliver)
      dispatcher.deliver_new_cart_emails(cart)
    end
  end

  describe '#on_approval_status_change' do
    it "sends to the requester" do
      dispatcher.on_approval_status_change(cart.approvals.first)
      expect(email_recipients).to eq(['requester@some-dot-gov.gov'])
    end
  end
end
