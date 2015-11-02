module Ncr
  class WorkOrderReapprovalChecker
    attr_reader :work_order

    def initialize(work_order)
      @work_order = work_order
    end

    def current_user
      work_order.modifier
    end

    def amount_increased?
      changes = work_order.previous_changes
      changes.key?('amount') && (work_order.amount > changes['amount'].first)
    end

    def budget_codes_changed?
      changes = work_order.previous_changes
      Ncr::WorkOrder.budget_code_fields.any? do |field|
        changes.key?(field.to_s)
      end
    end

    def budget_approver?
      work_order.budget_approvers.include?(current_user)
    end

    def requires_budget_reapproval?
      work_order.approved? && (
        self.amount_increased? || (
          self.budget_codes_changed? &&
          !self.budget_approver?
        )
      )
    end
  end
end
