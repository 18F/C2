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
        :name, :duty_station, :supervisor_id, :title_of_event,
        :event_provider, :purpose, :justification,
        :link, :instructions, :NFS_form, :cost_per_unit,
        :estimated_travel_expenses, :start_date, :end_date
      ]
    end
  end
end
