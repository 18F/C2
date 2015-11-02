module Ncr
  class WorkOrderUpdater
    attr_reader :flash, :model_changing, :work_order

    def initialize(work_order:, flash:, model_changing:)
      @flash = flash
      @model_changing = !!model_changing
      @work_order = work_order
    end

    def current_user
      work_order.modifier
    end

    def proposal
      work_order.proposal
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

    def reapprove_if_necessary
      if requires_budget_reapproval?
        work_order.restart_budget_approvals
        flash[:success] = "Successfully modified! This request now needs to be re-approved by budget."
      end
    end

    def after_update
      if model_changing
        work_order.setup_approvals_and_observers
        reapprove_if_necessary
        Dispatcher.on_proposal_update(proposal, work_order.modifier)
      end
    end
  end
end
