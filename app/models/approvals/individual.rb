module Approvals
  class Individual < Approval
    # Notify approvers when they can approve
    def on_actionable_entry(old_state, event)
      Dispatcher.email_approver(self)
    end

    # (Possibly) send a notification after each approval
    def on_approved_entry(old_state, event)
      super
      Dispatcher.on_approval_approved(self)
    end
  end
end
