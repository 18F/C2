class ProposalDecorator < Draper::Decorator
  delegate_all

  def detailed_status
    if object.status == "pending" && actionable_steps.any?
      "pending"
    else
      object.status
    end
  end

  def capitalized_detailed_status
    detailed_status.capitalize
  end

  def total_price
    client_data.try(:total_price) || ""
  end

  def number_approved
    object.individual_steps.completed.count
  end

  def total_step_users
    object.individual_steps.count
  end

  def final_completed_date
    if completed? && total_step_users > 0
      object.individual_steps.last.completed_at # TODO: Is sometimes nil
    else
      ""
    end
  end

  def total_completion_days
    if completed? && total_step_users > 0
      (final_completed_date.to_date - created_at.to_date).to_i
    else
      ""
    end
  end

  def final_step_label
    if total_step_users > 0
      "Final #{object.individual_steps.last.decorate.label} Completed"
    else
      "Final Step Completed"
    end
  end

  def steps_in_list_order
    object.individual_steps.with_users
  end

  def waiting_text_for_status_in_table
    actionable_step = currently_awaiting_steps.first
    if actionable_step
      actionable_step.decorate.waiting_text
    else
      # This should only ever happen in specs which create proposals but never
      # populate them with steps. Unfortunately we still have many of those.
      "This proposal has no steps"
    end
  end

  def step_text_for_user(key, user)
    step = existing_or_delegated_step_for(user)
    klass = step.class.name.demodulize.downcase.to_sym
    scope = [:decorators, :steps, klass]
    I18n.t(key, scope: scope)
  end

  def self.csv_headers(proposal)
    step_label = "Final Step Completed"
    if proposal
      step_label = proposal.decorate.final_step_label
    end
    ["Public ID", "Created", "Requester", "Status", step_label, "Duration"]
  end

  def as_csv
    [public_id, created_at, requester.display_name, detailed_status, final_completed_date, total_completion_days, client_data.csv_fields].flatten
  end

  def new_fields_for_display
    if client_data
      process_new_fields(client_data.decorate.new_display, client_data.decorate.client_code)
    else
      []
    end
  end

  def process_new_fields(fields, client)
    display = []
    fields.each do |field|
      display << { key: field, partial: client + "/fields/" + field }
    end
    display
  end

  def fields_for_display
    if client_data
      client_data.decorate.display
    else
      []
    end
  end

  def fields_for_email_display
    if client_data
      client_data.decorate.email_display
    else
      []
    end
  end

  def top_email_field
    if client_data
      client_data.decorate.top_email_field
    end
  end

  def ncr?
    client_data_type == "Ncr::WorkOrder"
  end

  private

  def actionable_steps
    @actionable_steps ||= object.individual_steps.actionable
  end
end
