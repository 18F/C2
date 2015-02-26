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
      end
      state :rejected do
        # partial approvals and rejections can't break out of this state
        event :partial_approve, :transitions_to => :rejected
        event :reject, :transitions_to => :rejected
        event :restart, :transitions_to => :pending
      end
    end

    validates :status, presence: true, inclusion: {in: self.statuses.map(&:to_s)}
  end

  module ClassMethods
    # returns an array of symbols
    def statuses
      self.workflow_spec.state_names
    end

    # returns an array of symbols
    def events
      workflow_spec.states.values.flat_map(&:events).flat_map(&:keys).uniq
    end
  end
end
