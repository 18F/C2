describe NcrDispatcher do
  let!(:cart) { FactoryGirl.create(:cart_with_approvals) }
  let(:approvals) { cart.ordered_approvals }
  let(:approval_1) { approvals.first }
  let(:approval_2) { approvals.second }
  let(:ncr_dispatcher) { NcrDispatcher.new }

  describe '#on_approval_approved' do
    it "sends to the requester for the last approval" do
      approval_1.approve!
      deliveries.clear

      ncr_dispatcher.on_approval_approved(approval_2)
      expect(email_recipients).to include('requester@some-dot-gov.gov')
    end

    it "doesn't send to the requester for the not-last approval" do
      ncr_dispatcher.on_approval_approved(approval_1)
      expect(email_recipients).to_not include('requester@some-dot-gov.gov')
    end
  end

  describe '#on_cart_rejected' do
    it "notifies the requester" do
      approval_1.update_attribute(:status, 'rejected') # avoid workflow
      ncr_dispatcher.on_cart_rejected(cart)
      expect(email_recipients).to include('requester@some-dot-gov.gov')
    end
  end

  describe '#requires_approval_notice?' do
    it 'returns true when the approval is last in the approver list' do
      expect(ncr_dispatcher.requires_approval_notice? approval_2).to eq true
    end

    it 'return false when the approval is not last in the approver list' do
      expect(ncr_dispatcher.requires_approval_notice? approval_1).to eq false
    end
  end
end
