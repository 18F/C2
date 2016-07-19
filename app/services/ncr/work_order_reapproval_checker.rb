module Ncr
  class WorkOrderReapprovalChecker
    attr_reader :work_order

    def initialize(work_order)
      @work_order = work_order
    end

    def requires_budget_reapproval?
      work_order_status &&
        (amount_increased? || protected_fields_changed?)
    end

    def could_require_budget_reapproval?
      work_order_status
    end

    def protected_fields_list
      protected_fields + [:amount]
    end

    private

    def work_order_status
      work_order.completed? &&
        work_order.requires_approval? &&
        !user_is_budget_approver? &&
        proposal_has_budget_approvals?
    end

    def user_is_budget_approver?
      work_order.budget_approvers.include?(current_user) || shares_budget_approver_delegator?
    end

    def shares_budget_approver_delegator?
      Ncr::WorkOrder.all_system_approvers.any? { |delegator| delegator.delegates_to?(current_user) }
    end

    def proposal_has_budget_approvals?
      !work_order.budget_approvals.empty?
    end

    def current_user
      work_order.modifier
    end

    def amount_increased?
      prev_amount = previous_val("amount")
      prev_amount && (work_order.amount > prev_amount)
    end

    def protected_fields_changed?
      protected_fields.any? do |field|
        previous_val(field) &&
          previous_val(field) != current_val(field)
      end
    end

    def protected_fields
      [
        :building_number,
        :function_code,
        :ncr_organization_id,
        :rwa_number,
        :soc_code
      ]
    end

    def previous_val(key)
      changes = work_order.previous_changes
      if changes[key.to_s]
        changes[key.to_s][0]
      end
    end

    def current_val(key)
      work_order.public_send(key)
    end
  end
end
