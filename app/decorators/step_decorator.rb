class StepDecorator < Draper::Decorator
  delegate_all

  def display_status
    if object.actionable?
      "pending"
    else
      object.status
    end
  end

  def role_name
    get_step_text(:role_name)
  end

  def action_name
    get_step_text(:execute_button)
  end

  def waiting_text
    get_step_text("status.waiting")
  end

  private

  def get_step_text(key)
    klass = object.class.name.demodulize.downcase.to_sym
    scope = [:decorators, :steps, klass]
    I18n.t(key, scope: scope)
  end
end
