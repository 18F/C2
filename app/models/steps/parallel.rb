module Steps
  class Parallel < Step
    validates :min_children_needed, numericality: { allow_blank: true }

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

        event :child_completed, transitions_to: :completed do |_|
          halt unless children_completed?
        end

        event :force_complete, transitions_to: :completed
        event :restart, transitions_to: :pending
      end

      state :completed do
        on_entry { notify_parent_completed }

        event :initialize, transitions_to: :completed do
          notify_parent_completed
          halt  # prevent state transition
        end

        event :child_completed, transitions_to: :completed do |_|
          halt  # additional steps do nothing
        end

        event :restart, transitions_to: :pending
      end
    end

    def on_actionable_entry(_, _)
      if child_steps.any?
        child_steps.each(&:initialize!)
      else
        force_complete!
      end
    end

    # overrides to allow for ratios. For example, if there are three child
    # steps, and min_children_needed is set to 2, only 2 of the 3 must
    # complete. When min_children_needed is 1, we create an "OR" situation
    def children_completed?
      needed = min_children_needed || child_steps.count
      child_steps.completed.count >= needed
    end
  end
end
