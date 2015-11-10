module Ncr
  class WorkOrderUpdater
    attr_reader :flash, :work_order

    def initialize(work_order:, flash:)
      @flash = flash
      @work_order = work_order
    end

    delegate :proposal, to: :work_order

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
      work_order.setup_approvals_and_observers
      reapprove_if_necessary
      Dispatcher.on_proposal_update(proposal, work_order.modifier)
    end
  end
end
