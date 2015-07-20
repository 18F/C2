module Approvals
  class Parallel < Approval
    workflow do
      on_transition { self.touch }

      state :pending do
        event :initialize, transitions_to: :actionable
      end

      state :actionable do
        # on_actionable_entry, below

        event(:initialize, transitions_to: :actionable) { halt } # noop
        event :child_approved, transitions_to: :approved do |_|
          halt unless self.min_required_met?
        end
        event :force_approve, transitions_to: :approved
      end

      state :approved do
        on_entry { self.notify_parent_approved }

        event :initialize, transitions_to: :approved do
          self.approved_notification
          halt  # no need to trigger a transition
        end

        event :child_approved, transitions_to: :approved do |_|
          halt  # additional approvals do nothing
        end
      end
    end

    def on_actionable_entry(old_state, event)
      if self.child_approvals.exists?
        self.child_approvals.each(&:initialize!)
      else
        self.force_approve!
      end
    end
  end
end
