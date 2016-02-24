module Ncr
  class ApprovalManager
    def initialize(work_order)
      @work_order = work_order
    end

    def system_approvers
      if %w(BA60 BA61).include?(work_order.expense_type)
        ba_6x_approvers
      else
        [ba_80_approver]
      end
    end

    def setup_approvals_and_observers
      if work_order.requires_approval?
        set_up_as_approvers
      else
        set_up_as_observers
      end
    end

    private

    attr_reader :work_order

    delegate :proposal, to: :work_order

    def set_up_as_approvers
      original_approvers = proposal.reload.individual_steps.non_pending.map(&:user)
      force_approvers(approvers)
      notify_removed_approvers(original_approvers)
    end

    def set_up_as_observers
      approvers.each do |user|
        work_order.add_observer(user)
      end
      # skip state machine
      proposal.update(status: "completed")
    end

    def approvers
      system_approvers.unshift(work_order.approving_official)
    end

    # Generally shouldn't be called directly as it doesn't account for
    # emergencies, or notify removed approvers
    def force_approvers(users)
      individuals = users.map do |user|
        proposal.existing_step_for(user) || Steps::Approval.new(user: user)
      end
      proposal.root_step = Steps::Serial.new(child_steps: individuals)
    end

    def notify_removed_approvers(original_approvers)
      current_approvers = proposal.individual_steps.non_pending.map(&:user)
      removed_approvers_to_notify = original_approvers - current_approvers
      DispatchFinder.run(proposal).on_approver_removal(removed_approvers_to_notify)
    end

    def ba_6x_approvers
      results = []

      if work_order.for_whsc_organization?
        # no tier 1
      elsif work_order.ba_6x_tier1_team?
        results << Ncr::Mailboxes.ba61_tier1_budget_team
      else
        results << Ncr::Mailboxes.ba61_tier1_budget
      end

      results << Ncr::Mailboxes.ba61_tier2_budget

      results
    end

    def ba_80_approver
      if work_order.for_ool_organization?
        Ncr::Mailboxes.ool_ba80_budget
      else
        Ncr::Mailboxes.ba80_budget
      end
    end
  end
end
