# Helper for handling workflow mechanics. Mix in with a model with the class
# method `workflow_setup`

module WorkflowModel
  extend ActiveSupport::Concern

  included do
    include Workflow

    workflow_column :status

    validates :status, presence: true, inclusion: {in: lambda{ |wf| statuses.map(&:to_s)}}
  end

  module ClassMethods
    # returns an array of symbols
    def statuses
      workflow_spec.state_names
    end

    # returns a set of symbols
    def events
      results = Set.new
      # collect events from every state
      workflow_spec.states.each do |state_name, state|
        state.events.each do |event_name, event|
          results << event_name
        end
      end

      results
    end
  end
end
