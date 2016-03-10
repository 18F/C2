module SearchHelper
  def proposal_status_options(selected_value)
    options_for_select(proposal_status_option_values, selected_value)
  end

  def proposal_status_value(value_key)
    proposal_status_option_values.find { |pair| pair[1] == value_key }[0]
  end

  def proposal_status_option_values
    [
      ["All Requests", "*"],
      ["Approved Requests", "approved"],
      ["In progress Requests", "pending"],
      ["Cancelled Requests", "cancelled"]
    ]
  end

  def proposal_expense_type_options(client_model, selected_value)
    expense_types = client_model.expense_type_options.unshift(["Any type", "*"])
    options_for_select(expense_types, selected_value)
  end
end
