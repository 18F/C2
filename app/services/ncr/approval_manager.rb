module Ncr
  START_OF_NEW_6X_APPROVAL_POLICY = "2016-07-05 00:00".in_time_zone("America/New_York")

  class ApprovalManager
    def initialize(work_order)
      @work_order = work_order
    end

    def system_approvers
      if %w(BA60 BA61).include?(work_order.expense_type)
        ba_6x_approvers
      else
        ba_80_approvers
      end
    end

    def setup_approvals_and_observers
      if work_order.requires_approval?
        set_up_as_approvers
      else
        set_up_as_observers
      end
    end

    def should_add_budget_approvers_to_6x?
      Time.zone.now < START_OF_NEW_6X_APPROVAL_POLICY
    end

    private

    attr_reader :work_order

    delegate :proposal, to: :work_order

    def set_up_as_approvers
      original_step_users = proposal.reload.individual_steps.non_pending.map(&:user)
      force_approvers(approvers)
      notify_removed_step_users(original_step_users)
    end

    def set_up_as_observers
      approvers.each do |user|
        work_order.add_observer(user)
      end
      # skip state machine
      proposal.update(status: "completed")
    end

    def approvers
      [work_order.approving_official] + system_approvers
    end

    # Generally shouldn't be called directly as it doesn't account for
    # emergencies, or notify removed approvers
    def force_approvers(users)
      new_child_steps = users.map do |user|
        proposal.existing_step_for(user) || Steps::Approval.new(user: user)
      end
      unless proposal.root_step && child_steps_unchanged?(proposal.root_step, new_child_steps)
        proposal.root_step = Steps::Serial.new(child_steps: new_child_steps)
      end
    end

    def child_steps_unchanged?(parent_step, new_steps)
      old_steps = parent_step.child_steps
      old_steps.size == new_steps.size && (old_steps & new_steps).size == old_steps.size
    end

    def notify_removed_step_users(original_step_users)
      current_step_users = proposal.individual_steps.non_pending.map(&:user)
      removed_step_users_to_notify = original_step_users - current_step_users
      DispatchFinder.run(proposal).on_step_user_removal(removed_step_users_to_notify)
    end

    def ba_6x_approvers
      results = []
      return results unless should_add_budget_approvers_to_6x?

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

    def ba_80_approvers
      if work_order.for_ool_organization?
        [Ncr::Mailboxes.ool_ba80_budget]
      else
        [Ncr::Mailboxes.ba80_budget]
      end
    end
  end
end
