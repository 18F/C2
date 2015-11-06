describe Ncr::WorkOrderReapprovalChecker do
  include ProposalSpecHelper

  describe '#protected_fields_changed?' do
    it "returns true when the value is changed" do
      expect(Ncr::WorkOrderReapprovalChecker).to receive(:protected_fields).and_return([:soc_code])

      work_order = create(:ncr_work_order, soc_code: '123')
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)

      work_order.update!(soc_code: '456')
      expect(checker.protected_fields_changed?).to eq(true)
    end

    it "returns false when the value is set for the first time" do
      expect(Ncr::WorkOrderReapprovalChecker).to receive(:protected_fields).and_return([:soc_code])

      work_order = create(:ncr_work_order, soc_code: nil)
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)

      work_order.update!(soc_code: '123')
      expect(checker.protected_fields_changed?).to eq(false)
    end

    it "returns false when the field changed isn't protected" do
      expect(Ncr::WorkOrderReapprovalChecker).to receive(:protected_fields).and_return([])

      work_order = create(:ncr_work_order, soc_code: '123')
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)

      work_order.update!(soc_code: '456')
      expect(checker.protected_fields_changed?).to eq(false)
    end
  end

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

    it "returns true if one of the protected fields is changed" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.update!(created_at: Time.zone.now) # just need to trigger an update

      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      expect(checker).to receive(:protected_fields_changed?).and_return(true)
      expect(checker.requires_budget_reapproval?).to eq(true)
    end

    it "returns false if none of the protected fields are changed" do
      work_order = create(:ncr_work_order)
      work_order.approve!
      work_order.update!(created_at: Time.zone.now) # just need to trigger an update

      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      expect(checker).to receive(:protected_fields_changed?).and_return(false)
      expect(checker.requires_budget_reapproval?).to eq(false)
    end

    it "returns false if the function code is changed by a budget approver" do
      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers
      fully_approve(work_order.proposal)

      work_order.modifier = work_order.budget_approvers.first
      work_order.update!(function_code: "PG789")

      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      expect(checker.requires_budget_reapproval?).to eq(false)
    end
  end

  describe '.protected_fields' do
    it "is a subset of the WorkOrder attributes" do
      all_fields = Ncr::WorkOrder.attribute_names.map(&:to_sym)
      protected_fields = Ncr::WorkOrderReapprovalChecker.protected_fields
      expect(all_fields).to include(*protected_fields)
    end
  end
end
