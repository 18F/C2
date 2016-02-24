# Represents a single user's ability to approve, the "leaves" of an approval
# chain
module Steps
  class Individual < Step
    belongs_to :user
    has_one :api_token, -> { fresh }, foreign_key: "step_id"
    has_many :delegations, through: :user, source: :outgoing_delegations
    has_many :delegates, through: :delegations, source: :assignee

    validate :user_is_not_requester
    validates :user, presence: true
    delegate :full_name, :email_address, to: :user, prefix: true
    scope :with_users, -> { includes :user }

    self.abstract_class = true

    workflow do
      on_transition { touch } # sets updated_at; https://github.com/geekq/workflow/issues/96

      state :pending do
        event :initialize, transitions_to: :actionable
      end

      state :actionable do
        event :initialize, transitions_to: :actionable do
          halt  # prevent state transition
        end

        event :complete, transitions_to: :completed
        event :restart, transitions_to: :pending
      end

      state :completed do
        on_entry do
<<<<<<< 98f9ab478598a0313a427317a7810015752c66de
          update(completed_at: Time.zone.now)
          notify_parent_completed
          Dispatcher.on_approval_approved(self)
=======
          update(approved_at: Time.zone.now)
          notify_parent_approved
          DispatchFinder.run(self.proposal).on_approval_approved(self)
>>>>>>> Sublcass Dispatcher with NcrDispatcher
        end

        event :initialize, transitions_to: :actionable do
          notify_parent_completed
          halt  # prevent state transition
        end

        event :restart, transitions_to: :pending
      end
    end

    protected

    def restart
      api_token.try(:expire!)
      super
    end

    def user_is_not_requester
      if user && user == proposal.requester
        errors.add(:user, "Cannot be Requester")
      end
    end
  end
end
