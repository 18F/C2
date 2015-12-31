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

  def generate_status_message
    if object.steps.non_pending.empty?
      progress_status_message
    else
      completed_status_message
    end
  end

  def completed_status_message
    "All #{number_approved} of #{total_approvers} approvals have been received. Please move forward with the purchase of ##{object.public_id}."
  end

  def progress_status_message
    "#{number_approved} of #{total_approvers} approved."
  end

  def step_text_for_user(key, user)
    step = existing_step_for(user)
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
