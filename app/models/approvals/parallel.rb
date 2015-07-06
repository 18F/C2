module Approvals
  class Parallel < Approval
    workflow do
      state :pending do
        event :make_actionable, transitions_to: :actionable
      end
      state :actionable do
        on_entry { self.child_approvals.each(&:make_actionable!) }
        event :child_approved, transitions_to: :approved do
          halt unless self.min_required_met?
        end
      end
      state :approved do
        event :child_approved, transitions_to: :approved do halt end   # additional approvals do nothing
      end
    end

    # By using a min_required, we can create a disjunction
    def min_required_met?
      min_required = self.min_required || self.child_approvals.count
      self.child_approvals.approved.count >= min_required
    end
  end
end
