# A node in an approval chain that requires its children be approved in order
module Steps
  class Serial < Step
    workflow do
      on_transition { self.touch } # sets updated_at; https://github.com/geekq/workflow/issues/96

      state :pending do
        event :initialize, transitions_to: :actionable
      end

      state :actionable do
        # on_actionable_entry, below

        event :initialize, transitions_to: :actionable do
          halt  # prevent state transition
        end
        event :child_approved, transitions_to: :approved do |child|
          self.init_child_after(child)
          halt unless self.children_approved?
        end
        event :force_approve, transitions_to: :approved
      end

      state :approved do
        on_entry { self.notify_parent_approved }

        event :initialize, transitions_to: :approved do
          self.notify_parent_approved
          halt  # prevent state transition
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

    # enforce initialization of children in sequence. If we hit one which is
    # already approved, it will notify us, and then  we'll notify the next
    def init_child_after(approval)
      if child_after = self.child_approvals.where('position > ?', approval.position).first
        child_after.initialize!
      end
    end
  end
end
