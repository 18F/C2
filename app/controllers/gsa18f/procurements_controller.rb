module Gsa18f
  class ProcurementsController < ClientDataController
    protected

    def format_client_data client_data_instance
      client_data_instance
    end

    def model_class
      Gsa18f::Procurement
    end

    def permitted_params
      Gsa18f::Procurement.permitted_params(params, @client_data_instance)
    end
  end
end
