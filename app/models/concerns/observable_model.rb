module ObservableModel
  extend ActiveSupport::Concern

  included do
    after_create ->{self.send_event :create}
    after_update ->{self.send_event :update}
    # Add more as needed
  end

  def send_event(event_name)
    ActiveSupport::Notifications.instrument(
      "#{self.class.model_name}.#{event_name}", self)
  end
end
