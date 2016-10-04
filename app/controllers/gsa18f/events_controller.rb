module Gsa18f
  class EventsController < ClientDataController
    MAX_UPLOADS_ON_NEW = 10

    protected

    def model_class
      Gsa18f::Event
    end

    def permitted_params
      Gsa18f::Event.permitted_params(params, @client_data_instance)
    end
  end
end
