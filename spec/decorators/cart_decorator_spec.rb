describe CartDecorator do
  let(:cart) { FactoryGirl.build(:cart).decorate }

  describe '#approvals_by_status' do
    it "orders by approved, rejected, then pending" do
      # make two approvals for each status, in random order
      statuses = Approval.statuses.map(&:to_s)
      statuses = statuses.dup + statuses.clone
      statuses.shuffle.each do |status|
        FactoryGirl.create(:approval, proposal_id: cart.proposal_id, status: status)
      end

      expect(cart.approvals_by_status.map(&:status)).to eq(%w(
        approved
        approved
        rejected
        rejected
        pending
        pending
      ))
    end
  end

  describe '#total_price' do
    context 'the client origin is NCR' do
      it 'gets price from the cart properties' do
        cart.setProp('origin','ncr')
        cart.setProp('amount','357.89')
        expect(cart.total_price).to eq 357.89
      end
    end

    context 'other client origins' do
      it 'returns 0, for the moment' do
        cart.setProp('origin','some-other-client')
        expect(cart.total_price).to eq(0.0)
      end
    end


  end
end
