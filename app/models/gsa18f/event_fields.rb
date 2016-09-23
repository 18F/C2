module Gsa18f
  class EventFields
    def initialize(event = nil)
      @event = event
    end

    def relevant
      default
    end

    private

    attr_reader :event

    def default
      [
        :duty_station, :supervisor_id, :title_of_event,
        :event_provider, :type_of_event, :cost_per_unit,
        :start_date, :end_date, :purpose, :justification, 
        :link, :instructions, :free_event, :nfs_form, 
        :travel_required, :estimated_travel_expenses
      ]
    end
  end
end
