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

        event :child_completed, transitions_to: :completed do |child|
          init_child_after(child)
          halt unless children_completed?
        end

        event :force_complete, transitions_to: :completed
        event :restart, transitions_to: :pending
      end

      # The equivalent of `def complete!`
      state :completed do
        on_entry { notify_parent_completed }

        event :initialize, transitions_to: :completed do
          notify_parent_completed
          halt  # prevent state transition
        end

        event :child_completed, transitions_to: :completed do |_|
          halt  # additional completions do nothing
        end

        event :restart, transitions_to: :pending
      end
    end

    def on_actionable_entry(_, _)
      first_step = child_steps.first
      if first_step
        first_step.initialize!
      else
        force_complete!
      end
    end

    # enforce initialization of children in sequence. If we hit one which is
    # already completed, it will notify us, and then  we'll notify the next
    def init_child_after(step)
      child_after = child_steps.find_by("position > ?", step.position)
      if child_after
        child_after.initialize!
      end
    end
  end
end
