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
      changes.key?("amount") && (work_order.amount > changes["amount"].first)
    end

    def protected_fields_changed?
      changes = work_order.previous_changes
      self.class.protected_fields.any? do |field|
        values = changes[field.to_s]
        values && values[0].present?
      end
    end

    def budget_approver?
      work_order.budget_approvers.include?(current_user)
    end

    def requires_budget_reapproval?
      work_order.approved? &&
        work_order.requires_approval? && (
        self.amount_increased? || (
          self.protected_fields_changed? &&
          !self.budget_approver?
        )
        )
    end

    def self.protected_fields
      [
        :building_number,
        :function_code,
        :org_code,
        :rwa_number,
        :soc_code
      ]
    end
  end
end
