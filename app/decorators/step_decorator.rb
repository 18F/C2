class StepDecorator < Draper::Decorator
  delegate_all

  def display_status
    if object.actionable?
      "pending"
    else
      object.status
    end
  end
end
