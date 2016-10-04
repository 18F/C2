module Gsa18f
  class EventsController < ClientDataController
    MAX_UPLOADS_ON_NEW = 10

    protected

    def format_client_data client_data_instance
      client_data_instance.each do |key, value|

        if value.empty?
          value = "--"
        end

        case key
          when "supervisor_id"
            display_value = value
            if(client_data_instance.supervisor_id.is_a? Integer){
              id = client_data_instance.supervisor_id
              supervisor = if User.find_by(id: id) then User.find(id).full_name else "--" end
              display_value = supervisor
            }
            client_data_instance[key] = { edit: value, display: display_value }
          else
            client_data_instance[key] = { edit: value, display: value }
        end
      end
      return client_data_instance
    end

    def model_class
      Gsa18f::Event
    end

    def permitted_params
      Gsa18f::Event.permitted_params(params, @client_data_instance)
    end
  end
end
