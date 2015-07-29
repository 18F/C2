# Represents a single user's ability to approve, the "leaves" in an approval chain
module Approvals
  class Individual < Approval
    belongs_to :user
    validates :user, presence: true
    delegate :full_name, :email_address, :to => :user, :prefix => true
    scope :with_users, -> { includes :user }

    has_one :api_token, -> { fresh }, foreign_key: "approval_id"

    workflow do
      on_transition { self.touch } # https://github.com/geekq/workflow/issues/96

      state :pending do
        event :initialize, transitions_to: :actionable
      end

      state :actionable do
        event :initialize, transitions_to: :actionable do
          halt  # prevent state transition
        end

        event :approve, transitions_to: :approved
      end

      state :approved do
        on_entry do
          self.update(approved_at: Time.now)
          self.notify_parent_approved
          Dispatcher.on_approval_approved(self)
        end

        event :initialize, transitions_to: :actionable do
          self.notify_parent_approved
          halt  # prevent state transition
        end
      end
    end
  end
end
