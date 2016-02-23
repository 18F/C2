class ProposalDecorator < Draper::Decorator
  delegate_all

  def number_approved
    object.individual_steps.approved.count
  end

  def total_approvers
    object.individual_steps.count
  end

  def steps_in_list_order
    object.individual_steps.with_users
  end

  def display_status
    if object.pending?
      "pending approval"
    else
      object.status
    end
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
end
