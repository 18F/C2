# A node in an approval chain that allows its child approvals to come in in
# any order
module Approvals
  class Parallel < Approval
    validates :min_children_needed, numericality: {allow_blank: true}

    workflow do
      on_transition { self.touch } # sets updated_at; https://github.com/geekq/workflow/issues/96

      state :pending do
        event :initialize, transitions_to: :actionable
        event :restart, transitions_to: :pending
      end

      state :actionable do
        # on_actionable_entry, below

        event :initialize, transitions_to: :actionable do
          halt  # prevent state transition
        end
        event :child_approved, transitions_to: :approved do |_|
          halt unless self.children_approved?
        end
        event :force_approve, transitions_to: :approved
        event :restart, transitions_to: :pending
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

        event :restart, transitions_to: :pending
      end
    end

    def on_actionable_entry(old_state, event)
      if self.child_approvals.any?
        self.child_approvals.each(&:initialize!)
      else
        self.force_approve!
      end
    end

    # overrides to allow for ratios. For example, if there are three child
    # approvals, and min_children_needed is set to 2, only 2 of the 3 must
    # approve. When min_children_needed is 1, we create an "OR" situation
    def children_approved?
      needed = self.min_children_needed || self.child_approvals.count
      self.child_approvals.approved.count >= needed
    end
  end
end
