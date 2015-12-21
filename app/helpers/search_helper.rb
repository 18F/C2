module SearchHelper
  def proposal_status_options(selected_value)
    options_for_select([ 
      ["All Requests", "*"],
      ["Approved Requests", "approved"],
      ["In progress Requests", "pending"],
      ["Cancelled Requests", "cancelled"]
    ], selected_value)
  end
end
