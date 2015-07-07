module Approvals
  class Individual < Approval
    # Notify approvers when they can approve
    def on_actionable_entry(old_state, event)
      Dispatcher.email_approver(self)
    end
  end
end
