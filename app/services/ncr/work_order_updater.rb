module Ncr
  class WorkOrderUpdater
    attr_reader :flash, :work_order

    def initialize(work_order:, flash:)
      @flash = flash
      @work_order = work_order
    end

    delegate :proposal, to: :work_order

    def run
      work_order.setup_approvals_and_observers
      reapprove_if_necessary
      DispatchFinder.run(proposal).
        on_proposal_update(modifier: work_order.modifier, needs_review: requires_budget_reapproval?)
    end

    private

    def reapprove_if_necessary
      if requires_budget_reapproval?
        work_order.restart_budget_approvals
        flash[:success] = "Successfully modified! This request now needs to be re-approved by budget."
      end
    end

    def requires_budget_reapproval?
      @_requires_budget_reapproval ||= checker.requires_budget_reapproval?
    end

    def checker
      Ncr::WorkOrderReapprovalChecker.new(work_order)
    end
  end
end
