module ThreeStateWorkflow
  extend ActiveSupport::Concern

  included do
    include Workflow
    workflow do
      state :pending do
        event :approve, :transitions_to => :approved
        event :reject, :transitions_to => :rejected
      end
      state :approved
      state :rejected
    end
  end
end
