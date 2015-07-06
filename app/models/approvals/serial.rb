module Approvals
  class Serial < Approval
    workflow do
      state :pending do
        event :make_actionable, transitions_to: :actionable
      end
      state :actionable do
        on_entry { self.trigger_next_child }
        event :child_approved, transitions_to: :approved do
          self.trigger_next_child
          halt unless self.child_approvals.where.not(status: 'approved').empty?
        end
      end
      state :approved
    end

    def trigger_next_child
      if next_approval = self.child_approvals.pending.first
        next_approval.make_actionable!
      end
    end
  end
end
