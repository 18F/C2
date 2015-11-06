module Ncr
  class WorkOrderReapprovalChecker
    attr_reader :work_order

    def initialize(work_order)
      @work_order = work_order
    end

    def current_user
      work_order.modifier
    end

    def previous_val(key)
      changes = work_order.previous_changes || {}
      changes[key.to_s].try(:first)
    end

    def amount_increased?
      prev_amount = previous_val("amount")
      prev_amount && (work_order.amount > prev_amount)
    end

    def protected_fields_changed?
      self.class.protected_fields.any? do |field|
        previous_val(field).present?
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
