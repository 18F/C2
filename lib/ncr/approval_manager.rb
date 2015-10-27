module Ncr
  class ApprovalManager
    attr_reader :work_order

    delegate :proposal, to: :work_order

    def initialize(work_order)
      @work_order = work_order
    end

    def system_approver_emails
      results = []
      if %w(BA60 BA61).include?(self.work_order.expense_type)
        unless self.work_order.organization.try(:whsc?)
          results << self.class.ba61_tier1_budget_mailbox
        end
        results << self.class.ba61_tier2_budget_mailbox
      else # BA80
        if self.work_order.organization.try(:ool?)
          results << self.class.ool_ba80_budget_mailbox
        else
          results << self.class.ba80_budget_mailbox
        end
      end

      results
    end

    def setup_approvals_and_observers
      emails = self.approvers_emails
      if self.work_order.emergency
        emails.each do |email|
          self.work_order.add_observer(email)
        end
        # skip state machine
        self.proposal.update(status: 'approved')
      else
        original_approvers = self.proposal.individual_approvals.non_pending.map(&:user)
        self.force_approvers(emails)
        self.notify_removed_approvers(original_approvers)
      end
    end

    def self.ba61_tier1_budget_mailbox
      self.approver_with_role('BA61_tier1_budget_approver')
    end

    def self.ba61_tier2_budget_mailbox
      self.approver_with_role('BA61_tier2_budget_approver')
    end

    def self.approver_with_role(role_name)
      users = User.with_role(role_name).where(client_slug: 'ncr')
      if users.empty?
        fail "Missing User with role #{role_name} -- did you run rake db:migrate and rake db:seed?"
      end
      users.first.email_address
    end

    def self.ba80_budget_mailbox
      self.approver_with_role('BA80_budget_approver')
    end

    def self.ool_ba80_budget_mailbox
      self.approver_with_role('OOL_BA80_budget_approver')
    end

    protected

    # Check the approvers, accounting for frozen approving official
    def approvers_emails
      emails = self.system_approver_emails
      if self.work_order.approver_email_frozen?
        emails.unshift(self.work_order.approving_official.email_address)
      else
        emails.unshift(self.work_order.approving_official_email)
      end
      emails
    end

    # Generally shouldn't be called directly as it doesn't account for
    # emergencies, or notify removed approvers
    def force_approvers(emails)
      individuals = emails.map do |email|
        user = User.for_email(email)
        user.update!(client_slug: 'ncr')
        # Reuse existing approvals, if present
        self.proposal.existing_approval_for(user) || Approvals::Individual.new(user: user)
      end
      self.proposal.root_approval = Approvals::Serial.new(child_approvals: individuals)
    end

    def notify_removed_approvers(original_approvers)
      current_approvers = self.proposal.individual_approvals.non_pending.map(&:user)
      removed_approvers_to_notify = original_approvers - current_approvers
      Dispatcher.on_approver_removal(self.proposal, removed_approvers_to_notify)
    end
  end
end
