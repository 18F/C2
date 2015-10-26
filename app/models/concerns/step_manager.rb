module StepManager
  extend ActiveSupport::Concern

  def add_step(step)
    if steps.length == 0
      steps << Steps::Serial.new
    end
    steps.first.child_approvals << step
    steps << step
  end
end
