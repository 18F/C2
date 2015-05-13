describe Cart do
  let(:cart) { FactoryGirl.create(:cart_with_approval_group) }

  describe 'partial approvals' do
    let (:cart) { FactoryGirl.create(:cart_with_approvals) }
    context "All approvals are in 'approved' status" do
      it 'updates a status based on the cart_id passed in from the params' do
        cart.approvals.update_all(status: 'approved')
        cart.partial_approve!
        expect(cart.approved?).to eq true
      end
    end

    context "Not all approvals are in 'approved'status" do
      it 'does not update the cart status' do
        cart.partial_approve!
        expect(cart.pending?).to eq true
      end
    end
  end

  describe '#default value should be correct' do
    it 'sets status to pending by default' do
      expect(cart.pending?).to eq true
    end
  end

  context 'scopes' do
    let(:approved_cart1) { FactoryGirl.create(:cart, status: 'approved') }
    let(:approved_cart2) { FactoryGirl.create(:cart, status: 'approved') }
    let(:pending_cart)  { FactoryGirl.create(:cart, status: 'pending') }
    let(:rejected_cart)   { FactoryGirl.create(:cart, status: 'rejected') }

    describe 'approved' do
      it "returns approved carts" do
        approved_cart1
        approved_cart2
        pending_cart
        expect(Cart.approved).to eq [approved_cart1, approved_cart2]
      end
    end

    describe 'open' do
      it 'returns open carts' do
        approved_cart1
        pending_cart
        expect(Cart.pending).to eq [pending_cart]
      end
    end

    describe 'closed' do
      it 'returns closed carts' do
        approved_cart1
        pending_cart
        rejected_cart
        expect(Cart.closed).to eq [approved_cart1, rejected_cart]
      end
    end

  end

  describe '#on_rejected_entry' do
    it 'sends only one rejection email' do
      cart = FactoryGirl.create(:cart_with_approvals)
      # skip workflow
      cart.approvals.first.update_attribute(:status, 'rejected')
      cart.reject!
      expect(email_recipients).to eq(['requester@some-dot-gov.gov'])

      cart.reject!
      expect(email_recipients).to eq(['requester@some-dot-gov.gov'])
    end
  end

  describe '#restart' do
    it 'resets approval states when rejected' do
      cart = FactoryGirl.create(:cart_with_approvals)

      cart.approvals.first.approve!
      cart.approvals.last.reject!
      cart.reload
      expect(cart.rejected?).to eq(true)

      cart.restart!

      expect(cart.pending?).to eq(true)
      expect(cart.approvals.length).to eq(2)
      expect(cart.approvals[0].pending?).to eq(true)
      expect(cart.approvals[1].pending?).to eq(true)
    end

    it "creates new API tokens" do
      cart = FactoryGirl.create(:cart_with_approvals)
      cart.approvals.each(&:create_api_token!)
      expect(cart.api_tokens.length).to eq(2)

      cart.restart!

      expect(cart.api_tokens.unscoped.expired.length).to eq(2)
      expect(cart.api_tokens.unexpired.length).to eq(2)
    end
  end
end
