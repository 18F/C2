class StepDecorator < Draper::Decorator
  delegate_all

  def detailed_status
    if object.status == "pending" || object.status == "actionable"
      I18n.t("decorators.steps.status.pending")
    elsif object.status = "completed"
      "#{I18n.t('decorators.steps.status.completed')} #{I18n.l(object.completed_at, format: :date)}"
    end

  end

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

  def noun
    get_step_text(:noun)
  end

  def adjective
    get_step_text(:adjective)
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
