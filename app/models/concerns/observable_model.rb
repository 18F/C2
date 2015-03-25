module ObservableModel
  extend ActiveSupport::Concern

  included do
    after_create :send_create_event
    # Add more as needed
  end

  def send_create_event
    ActiveSupport::Notifications.instrument("#{self.class.model_name}.create",
                                            self)
  end
end
