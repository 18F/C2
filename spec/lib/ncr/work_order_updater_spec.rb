describe Ncr::WorkOrderUpdater do
  describe '#requires_budget_reapproval?' do
    it "returns false by when the amount is decreased" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.update!(amount: work_order.amount - 1)

      updater = Ncr::WorkOrderUpdater.new(
        work_order: work_order,
        flash: {},
        model_changing: true
      )
      expect(updater.requires_budget_reapproval?).to eq(false)
    end

    it "returns true if amount is increased" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.update!(amount: work_order.amount + 1)

      updater = Ncr::WorkOrderUpdater.new(
        work_order: work_order,
        flash: {},
        model_changing: true
      )
      expect(updater.requires_budget_reapproval?).to eq(true)
    end

    it "returns true if the function code is changed" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.update!(function_code: 'foo')

      updater = Ncr::WorkOrderUpdater.new(
        work_order: work_order,
        flash: {},
        model_changing: true
      )
      expect(updater.requires_budget_reapproval?).to eq(true)
    end
  end
end
