module Ncr
  class ApprovalManager
    def initialize(work_order)
      @work_order = work_order
    end

    def system_approver_emails
      if %w(BA60 BA61).include?(work_order.expense_type)
        ba_6x_approver_emails
      else
        [ba_80_approver_email]
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

    # Check the approvers, accounting for frozen approving official
    def approvers_emails
      emails = system_approver_emails
      if work_order.approver_email_frozen?
        emails.unshift(work_order.approving_official.email_address)
      else
        emails.unshift(work_order.approving_official_email)
      end
      emails
    end

    # Generally shouldn't be called directly as it doesn't account for
    # emergencies, or notify removed approvers
    def force_approvers(emails)
      individuals = emails.map do |email|
        user = User.for_email(email)
        user.update!(client_slug: "ncr")
        # Reuse existing approvals, if present
        proposal.existing_approval_for(user) || Steps::Approval.new(user: user)
      end
      proposal.root_step = Steps::Serial.new(child_approvals: individuals)
    end

    def notify_removed_approvers(original_approvers)
      current_approvers = proposal.individual_steps.non_pending.map(&:user)
      removed_approvers_to_notify = original_approvers - current_approvers
      Dispatcher.on_approver_removal(proposal, removed_approvers_to_notify)
    end

    def ba_6x_approver_emails
      results = []

      unless work_order.for_whsc_organization?
        results << Ncr::Mailboxes.ba61_tier1_budget
      end

      results << Ncr::Mailboxes.ba61_tier2_budget

      results
    end

    def ba_80_approver_email
      if work_order.for_ool_organization?
        Ncr::Mailboxes.ool_ba80_budget
      else
        Ncr::Mailboxes.ba80_budget
      end
    end

    def set_up_as_observers
      approvers_emails.each do |email|
        work_order.add_observer(email)
      end
      # skip state machine
      proposal.update(status: "approved")
    end

    def set_up_as_approvers
      original_approvers = proposal.individual_steps.non_pending.map(&:user)
      force_approvers(approvers_emails)
      notify_removed_approvers(original_approvers)
    end
  end
end
