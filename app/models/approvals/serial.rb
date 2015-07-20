module Approvals
  class Serial < Approval
    workflow do
      on_transition { self.touch }

      state :pending do
        event :initialize, transitions_to: :actionable
      end

      state :actionable do
        # on_actionable_entry, below

        event(:initialize, transitions_to: :actionable) { halt } # noop
        event :child_approved, transitions_to: :approved do |child|
          self.init_child_after(child)
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
      if first_approval = self.child_approvals.first
        first_approval.initialize!
      else
        self.force_approve!
      end
    end

    def init_child_after(approval)
      if child_after = self.child_approvals.where('position > ?', approval.position).first
        child_after.initialize!
      end
    end
  end
end
