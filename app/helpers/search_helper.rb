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
    expense_types = client_model.expense_type_options.unshift(["Any type", "*"])
    options_for_select(expense_types, selected_value)
  end
end
