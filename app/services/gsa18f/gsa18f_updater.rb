module Gsa18f
  class Gsa18fUpdater
    def initialize(gsa18f_proposal:, update_comment:)
      @gsa18f_proposal = gsa18f_proposal
      @update_comment = update_comment
    end

    delegate :proposal, to: :gsa18f_proposal

    def run
      gsa18f_proposal.setup_approvals_and_observers
      reapprove_if_necessary
      DispatchFinder.
        run(proposal).
        on_proposal_update(
          needs_review: requires_budget_reapproval?,
          comment: @update_comment
        )
    end

    private

    attr_reader :gsa18f_proposal

    def reapprove_if_necessary
      if requires_budget_reapproval?
        gsa18f_proposal.restart_budget_approvals
      end
    end

    def requires_budget_reapproval?
      @_requires_budget_reapproval ||= checker.requires_budget_reapproval?
    end

    def checker
      Ncr::WorkOrderReapprovalChecker.new(gsa18f_proposal)
    end
  end
end
