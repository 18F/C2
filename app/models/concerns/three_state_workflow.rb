module ThreeStateWorkflow
  extend ActiveSupport::Concern

  included do
    include Workflow

    workflow do
      state :pending do
        # partial *may* trigger a full approval
        event :partial_approve, :transitions_to => :pending
        event :approve, :transitions_to => :approved
        event :reject, :transitions_to => :rejected
        event :restart, :transitions_to => :pending
      end
      state :approved do
        event :restart, :transitions_to => :pending
        event :approve, :transitions_to => :approved
        event :partial_approve, :transitions_to => :approved
      end
      state :rejected do
        # partial approvals and rejections can't break out of this state
        event :partial_approve, :transitions_to => :rejected
        event :reject, :transitions_to => :rejected
        event :restart, :transitions_to => :pending
        event :approve, :transitions_to => :rejected
      end
    end

    validates :status, presence: true, inclusion: {in: self.statuses.map(&:to_s)}
  end

  module ClassMethods
    # returns an array of symbols
    def statuses
      self.workflow_spec.state_names
    end

    # returns a set of symbols
    def events
      results = Set.new
      # collect events from every state
      self.workflow_spec.states.each do |state_name, state|
        state.events.each do |event_name, event|
          results << event_name
        end
      end

      results
    end
  end
end
