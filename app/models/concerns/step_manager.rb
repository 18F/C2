module StepManager
  extend ActiveSupport::Concern

  def add_initial_steps(step_array)
    self.root_step = Steps::Serial.new(child_approvals: step_array)
  end
end
