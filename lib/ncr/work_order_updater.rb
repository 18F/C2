module Ncr
  class WorkOrderUpdater
    attr_reader :flash, :model_changing, :work_order

    def initialize(work_order:, flash:, model_changing:)
      @flash = flash
      @model_changing = !!model_changing
      @work_order = work_order
    end

    def proposal
      work_order.proposal
    end

    def requires_budget_reapproval?
      checker = Ncr::WorkOrderReapprovalChecker.new(work_order)
      checker.requires_budget_reapproval?
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
