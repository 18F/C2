# Represents a single user's ability to approve, the "leaves" in an approval chain
module Approvals
  class Individual < Approval
    workflow do
      on_transition { self.touch } # https://github.com/geekq/workflow/issues/96

      state :pending do
        event :make_actionable, transitions_to: :actionable
      end
      state :actionable do
        event :approve, transitions_to: :approved
      end
      state :approved
    end
  end
end
