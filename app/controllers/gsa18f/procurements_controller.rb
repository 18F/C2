module Gsa18f
  class ProcurementsController < UseCaseController
    before_filter :redirect_if_cart_cant_be_edited, only: [:edit, :update]


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

    def redirect_if_cart_cant_be_edited
      if self.procurement.approved?
        redirect_to new_gsa18f_procurement_path, :alert => "That proposal's already approved. New proposal?"
      elsif self.procurement.requester != current_user
        redirect_to new_gsa18f_procurement_path, :alert => 'You cannot restart that proposal'
      end
    end
  end
end
