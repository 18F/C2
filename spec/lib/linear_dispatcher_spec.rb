describe LinearDispatcher do
  let(:cart) { FactoryGirl.create(:cart) }
  let(:dispatcher) { LinearDispatcher.new }
  let(:requester) { FactoryGirl.create(:user, email_address: 'requester@some-dot-gov-domain.gov') }
  let(:approver) { FactoryGirl.create(:user, email_address: 'approver@some-dot-gov-domain.gov') }

  describe '#next_approval' do
    context "no approvals" do
      it "returns nil" do
        expect(dispatcher.next_approval(cart)).to eq(nil)
      end
    end

    it "returns nil if all are non-pending" do
      cart.approvals.create!(role: 'approver', status: 'approved')
      expect(dispatcher.next_approval(cart)).to eq(nil)
    end

    it "returns the first pending approval by position" do
      cart.approvals.create!(position: 6, role: 'approver')
      last_approval = cart.approvals.create!(position: 5, role: 'approver')

      expect(dispatcher.next_approval(cart)).to eq(last_approval)
    end

    it "skips approved approvals" do
      first_approval = cart.approvals.create!(position: 6, role: 'approver')
      cart.approvals.create!(position: 5, role: 'approver', status: 'approved')

      expect(dispatcher.next_approval(cart)).to eq(first_approval)
    end

    it "skips non-approvers" do
      cart.approvals.create!(role: 'observer')
      approval = cart.approvals.create!(role: 'approver')

      expect(dispatcher.next_approval(cart)).to eq(approval)
    end
  end

  describe '#deliver_new_cart_emails' do
    before do
      cart.approvals << FactoryGirl.create(:approval, cart_id: cart.id, user_id: requester.id, status: 'pending', role: 'requester', position: 1)
    end

    it "sends emails to the first approver" do
      approver
      approval = cart.approvals.create!(user_id: approver.id, role: 'approver')
      expect(dispatcher).to receive(:email_approver).with(approval)

      dispatcher.deliver_new_cart_emails(cart)
    end

    it "sends a cart notification email to observers" do
      cart.approvals.create!(role: 'observer')
      expect(dispatcher).to receive(:email_observers).with(cart)

      dispatcher.deliver_new_cart_emails(cart)
    end
  end

  xdescribe '#on_approval_status_change' do
    it "sends to the requester and the next approver" do
      dispatcher.on_approval_status_change(cart.approvals.first)
      expect(email_recipients).to eq([
        'approver2@some-dot-gov.gov',
        'requester@some-dot-gov.gov'
      ])
    end
  end
end
