module Approvals
  class Individual < Approval
    workflow do
      on_transition { self.touch }

      state :pending do
        event :initialize, transitions_to: :actionable
      end

      state :actionable do
        on_entry { Dispatcher.email_approver(self) }

        event(:initialize, transitions_to: :actionable) { halt } # noop
        event :approve, transitions_to: :approved
      end

      state :approved do
        on_entry do
          self.notify_parent_approved
          Dispatcher.on_approval_approved(self)   # (Possibly) send a notification after each approval
        end

        event :initialize, transitions_to: :approved do 
          self.notify_parent_approved
          halt  # no need to trigger a transition
        end
      end
    end
  end
end
