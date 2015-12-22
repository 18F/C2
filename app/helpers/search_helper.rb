module SearchHelper
  def proposal_status_options(selected_value)
    options_for_select([ 
      ["All Requests", "*"],
      ["Approved Requests", "approved"],
      ["In progress Requests", "pending"],
      ["Cancelled Requests", "cancelled"]
    ], selected_value)
  end

  def proposal_expense_type_options(client_model, selected_value)
    options_for_select(client_model.expense_type_options, selected_value)
  end
end
