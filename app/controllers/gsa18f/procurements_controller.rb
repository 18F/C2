module Gsa18f
  class ProcurementsController < UseCaseController
    def create
      super

      # TODO move to after_create
      if self.errors.empty?
        self.procurement.add_approvals
      end
    end


    protected

    def model_class
      Gsa18f::Procurement
    end

    def permitted_params
      fields = Gsa18f::Procurement.relevant_fields(
        params[:gsa18f_procurement][:recurring])
      params.require(:gsa18f_procurement).permit(:name, *fields)
    end

    def procurement
      @procurement ||= self.find_model_instance
    end

    # TODO move to UseCaseController
    def errors
      self.procurement.valid? # force validation
      self.procurement.errors.full_messages
    end
  end
end
