module EventSpecHelper
  def create_event
    client_data = Gsa18f::Event.new(
      duty_station: "dc",
      supervisor_id: 1,
      title_of_event: "eventTitle",
      event_provider: "EventProvider",
      purpose: "eventPurpose",
      justification: "event justification",
      link: "gsa.gov",
      instructions: "Event Instructions",
      cost_per_unit: 100,
      estimated_travel_expenses: 100,
      type_of_event: 0,
      free_event: false,
      travel_required: false
    )
    create(:proposal, client_data: client_data)
  end
end
