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
          update(completed_at: Time.zone.now)
          notify_parent_completed
          DispatchFinder.run(self.proposal).step_complete(self)
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
      update_attributes!(completer_id: nil, completed_at: nil)
      super
    end

    def user_is_not_requester
      if user && user == proposal.requester
        errors.add(:user, "Cannot be Requester")
      end
    end
  end
end
