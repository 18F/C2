module Ncr
  class WorkOrderUpdater
    def initialize(work_order:, update_comment:)
      @work_order = work_order
      @update_comment = update_comment
    end

    delegate :proposal, to: :work_order

    def run
      work_order.setup_approvals_and_observers
      reapprove_if_necessary
      DispatchFinder.
        run(proposal).
        on_proposal_update(
          needs_review: requires_budget_reapproval?,
          comment: @update_comment
        )
    end

    private

    attr_reader :work_order

    def reapprove_if_necessary
      if requires_budget_reapproval?
        work_order.restart_budget_approvals
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
