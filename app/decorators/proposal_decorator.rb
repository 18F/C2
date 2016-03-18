class ProposalDecorator < Draper::Decorator
  delegate_all

  def detailed_status
    if object.status == "pending" && object.individual_steps.any?
      actionable_step = object.individual_steps.select { |individual_step| individual_step.status == "actionable" }.last
      "pending #{actionable_step.decorate.noun}"
    else
      object.status
    end
  end

  def display_status
    if object.pending?
      "pending approval"
    else
      object.status
    end
  end

  def total_price
    client_data.try(:total_price) || ""
  end

  def number_approved
    object.individual_steps.completed.count
  end

  def total_approvers
    object.individual_steps.count
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

  def self.csv_headers
    ["Public ID", "Created", "Requester", "Status"]
  end

  def as_csv
    [public_id, created_at, requester.display_name, display_status, client_data.csv_fields].flatten
  end

  def fields_for_email_display
    if client_data
      client_data.decorate.public_send(:email_display)
    else
      []
    end
  end

  def top_email_field
    if client_data
      client_data.decorate.public_send(:top_email_field)
    end
  end
end
