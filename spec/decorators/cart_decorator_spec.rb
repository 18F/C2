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
end
