module SearchHelper
  include Ncr::WorkOrdersHelper

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

  def proposal_org_code_options(selected_value)
    org_codes_hash = organization_options
    org_codes_array = org_codes_hash.map { |h| [h[:name], h[:id].to_s] }
    org_codes_array.sort! { |a, b| a[0] <=> b[0] }
    org_codes_array.unshift(["Any code", "*"])
    options_for_select(org_codes_array, selected_value)
  end

  def proposal_building_number_options(selected_value)
    building_numbers = Ncr::BUILDING_NUMBERS.clone
    building_numbers.unshift(["Any building", "*"])
    options_for_select(building_numbers, selected_value)
  end

  def search_results_total(proposals_data)
    if proposals_data && proposals_data.es_response
      proposals_data.es_response.results.total || 0
    else
      0
    end
  end

  def created_at_time_string(dtim_string)
    if dtim_string.to_s =~ /TO now/
      ""
    elsif dtim_string.present? && Time.zone.parse(dtim_string)
      Time.zone.parse(dtim_string).utc.strftime("%F")
    else
      ""
    end
  end
end
