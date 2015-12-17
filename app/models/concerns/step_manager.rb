module StepManager
  extend ActiveSupport::Concern

  def add_initial_steps(step_array)
    self.root_step = Steps::Serial.new(child_approvals: step_array)
  end

  def root_step=(root)
    old_steps = steps.to_a
    step_list = root.pre_order_tree_traversal
    step_list.each { |a| a.proposal = self }
    self.steps = step_list
    # position may be out of whack, so we reset it
    step_list.each_with_index do |step, idx|
      step.set_list_position(idx + 1) # start with 1
    end

    clean_up_old_steps(old_steps, step_list)

    root.initialize!
    reset_status
  end

  def clean_up_old_steps(old_steps, step_list)
    # destroy any old steps that are not a part of step list
    (old_steps - step_list).each do |step|
      step.destroy if Step.exists?(step.id)
    end
  end

  # Steps in which someone can take action
  def currently_awaiting_steps
    individual_steps.actionable
  end

  def currently_awaiting_approvers
    approvers.merge(currently_awaiting_steps)
  end

  def awaiting_approver?(user)
    currently_awaiting_approvers.include?(user)
  end

  def approver_email_frozen?
    approval = individual_steps.first
    approval && !approval.actionable?
  end

  def ineligible_approvers
    [requester]
  end
end
