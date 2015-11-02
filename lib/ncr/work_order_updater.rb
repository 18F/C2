module Ncr
  class WorkOrderUpdater
    attr_reader :flash

    def initialize(work_order:, flash:, model_changing:)
      @model_instance = work_order
      @model_changing = model_changing
      @flash = flash
    end

    def current_user
      @model_instance.modifier
    end

    def proposal
      @model_instance.proposal
    end

    def amount_increased?
      changes = @model_instance.previous_changes
      changes.key?('amount') && (@model_instance.amount > changes['amount'].first)
    end

    def budget_codes_changed?
      changes = @model_instance.previous_changes
      Ncr::WorkOrder.budget_code_fields.any? do |field|
        changes.key?(field.to_s)
      end
    end

    def budget_approver?
      @model_instance.budget_approvers.include?(current_user)
    end

    def requires_budget_reapproval?
      @model_instance.approved? && (
        self.amount_increased? || (
          self.budget_codes_changed? &&
          !self.budget_approver?
        )
      )
    end

    def reapprove_if_necessary
      if requires_budget_reapproval?
        @model_instance.restart_budget_approvals
        flash[:success] = "Successfully modified! This request now needs to be re-approved by budget."
      end
    end

    def after_update
      if @model_changing
        @model_instance.setup_approvals_and_observers
        reapprove_if_necessary
        Dispatcher.on_proposal_update(proposal, @model_instance.modifier)
      end
    end
  end
end
