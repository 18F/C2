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
    klass = object.class.name.demodulize.downcase.to_sym
    scope = [:decorators, :steps, klass]
    I18n.t(:role_name, scope: scope)
  end
end
