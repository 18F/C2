module WorkflowHelper
  module ThreeStateWorkflow
    extend ActiveSupport::Concern

    included do
      include Workflow
      workflow do
        state :pending
        state :approved
        state :rejected
      end
    end
  end
end
