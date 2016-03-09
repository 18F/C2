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

    it "returns true if one of the protected fields is changed" do
      work_order = create(:ncr_work_order, function_code: "PGABC")
      work_order.approve!

      work_order.update!(function_code: "PG123")
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)

      expect(checker.requires_budget_reapproval?).to eq(true)
    end

    it "returns false if a protected field is set for the first time" do
      work_order = create(:ncr_work_order, function_code: nil)
      work_order.approve!

      work_order.update!(function_code: "PG123")
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)

      expect(checker.requires_budget_reapproval?).to eq(false)
    end

    it "returns false if none of the protected fields are changed" do
      work_order = create(:ncr_work_order)
      work_order.approve!

      work_order.update!(created_at: Time.zone.now)
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      expect(checker.requires_budget_reapproval?).to eq(false)
    end

    it "returns false if the function code is changed by a budget approver" do
      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers
      fully_approve(work_order.proposal)
      work_order.reload

      work_order.modifier = work_order.budget_approvers.first
      work_order.update!(function_code: "PG789")
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)

      expect(checker.requires_budget_reapproval?).to eq(false)
    end

    it "returns false if a protected field is changed by a budget approver delegate" do
      work_order = create(:ncr_work_order)
      work_order.setup_approvals_and_observers
      budget_approver = work_order.steps.last.user
      delegate_user = create(:user)
      create(:user_delegate, assigner: budget_approver, assignee: delegate_user)
      fully_approve(work_order.proposal, delegate_user)
      work_order.reload

      work_order.modifier = delegate_user
      work_order.update!(function_code: "PG789")
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)

      expect(checker.requires_budget_reapproval?).to eq(false)
    end
  end
end
