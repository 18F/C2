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

  def action_status
    I18n.t("decorators.steps.summary.action", display_position: object.position - 1,
                                              completed: completed,
                                              name: object.completed_by.full_name)
  end

  def label
    get_step_text(:label)
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

  def completed
    get_step_text(:completed)
  end

  private

  def get_step_text(key)
    klass = object.class.name.demodulize.downcase.to_sym
    scope = [:decorators, :steps, klass]
    I18n.t(key, scope: scope)
  end
end
