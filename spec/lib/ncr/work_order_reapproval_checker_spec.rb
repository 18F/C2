describe Ncr::WorkOrderReapprovalChecker do
  include ProposalSpecHelper

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

    it "returns false if the function code is changed by a budget approver" do
      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers
      fully_approve(work_order.proposal)

      work_order.modifier = work_order.budget_approvers.first
      work_order.update!(function_code: 'foo')

      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      expect(checker.requires_budget_reapproval?).to eq(false)
    end
  end
end
