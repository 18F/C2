describe Ncr::WorkOrderReapprovalChecker do
  describe '#requires_budget_reapproval?' do
    it "returns false by when the amount is decreased" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.update!(amount: work_order.amount - 1)

      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      expect(checker.requires_budget_reapproval?).to eq(false)
    end

    it "returns true if amount is increased" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.update!(amount: work_order.amount + 1)

      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      expect(checker.requires_budget_reapproval?).to eq(true)
    end

    it "returns true if the function code is changed" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.update!(function_code: 'foo')

      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      expect(checker.requires_budget_reapproval?).to eq(true)
    end
  end
end
