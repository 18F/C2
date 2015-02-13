describe NcrDispatcher do
    let(:cart) { FactoryGirl.create(:cart) }
    let(:approval_1) { FactoryGirl.create(:approval, cart_id: cart.id, role: 'approver', position: 1) }
    let(:approval_2) { FactoryGirl.create(:approval, cart_id: cart.id, role: 'approver', position: 2) }
    let(:ncr_dispatcher) { NcrDispatcher.new }

  describe '#requires_approval_notice?' do
    it 'returns true when the approval is last in the approver list' do
      approval_1
      approval_2
      expect(ncr_dispatcher.requires_approval_notice? approval_2).to eq true
    end

    it 'return false when the approval is not last in the approver list' do
      approval_1
      approval_2
      expect(ncr_dispatcher.requires_approval_notice? approval_1).to eq false
    end
  end
end
