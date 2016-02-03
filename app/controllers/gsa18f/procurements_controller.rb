module Gsa18f
  class ProcurementsController < ClientDataController
    def update
      @client_data_instance.assign_attributes(permitted_params)
      super
    end

    protected

    def model_class
      Gsa18f::Procurement
    end

    def permitted_params
      params.require(:gsa18f_procurement).permit(*procurement_params)
    end

    def procurement_params
      Gsa18f::ProcurementFields.new.relevant(params[:gsa18f_procurement][:recurring])
    end

    def add_steps
      super
      if errors.empty?
        @client_data_instance.add_steps
      end
    end
  end
end
