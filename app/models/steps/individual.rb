module Steps
  class Individual < Step
    has_many :delegations, through: :user, source: :outgoing_delegations
    has_many :delegates, through: :delegations, source: :assignee

    validates :user, presence: true
    delegate :full_name, :email_address, to: :user, prefix: true

    attr_accessor :skip_notifications

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
          unless skip_notifications
            DispatchFinder.run(self.proposal).step_complete(self)
          end
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
      self.class.transaction do
        api_token.try(:expire!)
        update_attributes!(completer_id: nil, completed_at: nil)
        super
      end
    end
  end
end
