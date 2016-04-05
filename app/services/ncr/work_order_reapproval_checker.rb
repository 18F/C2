module Ncr
  class WorkOrderReapprovalChecker
    attr_reader :work_order

    def initialize(work_order)
      @work_order = work_order
    end

    def requires_budget_reapproval?
      work_order.completed? &&
        work_order.requires_approval? &&
        !budget_approver? &&
        (amount_increased? || protected_fields_changed?)
    end

    private

    def budget_approver?
      work_order.budget_approvers.include?(current_user) || tier2_budget_approver_delegates?
    end

    def tier2_budget_approver_delegates?
      tier2_budget_approvers.any? { |tier2_user| tier2_user.delegates_to?(current_user) }
    end

    def tier2_budget_approvers
      [Ncr::Mailboxes.ba61_tier2_budget, Ncr::Mailboxes.ba80_budget, Ncr::Mailboxes.ool_ba80_budget]
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
