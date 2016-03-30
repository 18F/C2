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
      ["Completed Requests", "completed"],
      ["In progress Requests", "pending"],
      ["Cancelled Requests", "canceled"]
    ]
  end

  def proposal_expense_type_options(client_model, selected_value)
    expense_types = client_model.expense_type_options.unshift(["Any type", "*"])
    options_for_select(expense_types, selected_value)
  end

  def search_results_total(proposals_data)
    if proposals_data && proposals_data.es_response
      proposals_data.es_response.results.total || 0
    else
      0
    end
  end

  def created_at_time_string(dtim_string)
    if dtim_string.to_s.match(/TO now/)
      ""
    elsif dtim_string.present? && Time.parse(dtim_string)
      Time.parse(dtim_string).strftime("%F")
    else
      ""
    end
  end
end
