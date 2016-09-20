module Gsa18f
  class TrainingsController < ClientDataController
    protected

    def model_class
      Gsa18f::Training
    end

    def permitted_params
      Gsa18f::Training.permitted_params(params, @client_data_instance)
    end
  end
end
