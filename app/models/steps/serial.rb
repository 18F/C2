# A node in an approval chain that requires its children be approved in order
module Steps
  class Serial < Step
    workflow do
      on_transition { touch } # sets updated_at; https://github.com/geekq/workflow/issues/96

      state :pending do
        event :initialize, transitions_to: :actionable
        event :restart, transitions_to: :pending
      end

      state :actionable do
        # on_actionable_entry, below

        event :initialize, transitions_to: :actionable do
          halt  # prevent state transition
        end
        event :child_approved, transitions_to: :approved do |child|
          init_child_after(child)
          halt unless children_approved?
        end
        event :force_approve, transitions_to: :approved
        event :restart, transitions_to: :pending
      end

      state :approved do
        on_entry { notify_parent_approved }

        event :initialize, transitions_to: :approved do
          notify_parent_approved
          halt  # prevent state transition
        end

        event :child_approved, transitions_to: :approved do |_|
          halt  # additional approvals do nothing
        end

        event :restart, transitions_to: :pending
      end
    end

    def on_actionable_entry(_, _)
      first_approval = child_approvals.first
      if first_approval
        first_approval.initialize!
      else
        force_approve!
      end
    end

    # enforce initialization of children in sequence. If we hit one which is
    # already approved, it will notify us, and then  we'll notify the next
    def init_child_after(approval)
      child_after = child_approvals.find_by("position > ?", approval.position)
      if child_after
        child_after.initialize!
      end
    end
  end
end
