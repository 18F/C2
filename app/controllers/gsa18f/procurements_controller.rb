module Gsa18f
  class ProcurementsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :redirect_if_cart_cant_be_edited, only: [:edit, :update]

    def new
      @procurement = Gsa18f::Procurement.new
      render 'form'
    end

    def create
      @procurement = Gsa18f::Procurement.new(permitted_params)
      # TODO unify with how the factories create model instances
      @procurement.build_proposal(flow: 'linear', requester: current_user)
      if self.errors.empty?
        @procurement.requester = current_user
        @procurement.save
        @procurement.add_approvals
        Dispatcher.deliver_new_proposal_emails(@procurement)
        flash[:success] = "Procurement submitted!"
        redirect_to @procurement
      else
        flash[:error] = errors
        render 'form'
      end
    end

    def edit
      @procurement = self.procurement
      render 'form'
    end

    def update
      @procurement = self.procurement
      @procurement.update(permitted_params)
      if self.errors.empty?
        @procurement.restart!
        flash[:success] = "Procurement resubmitted!"
        redirect_to @procurement
      else
        flash[:error] = errors
        render 'form'
      end
    end

    protected

    def permitted_params
      fields = Gsa18f::Procurement.relevant_fields(
        params[:gsa18f_procurement][:recurring])
      params.require(:gsa18f_procurement).permit(:name, *fields)
    end

    def procurement
      @procurement ||= Gsa18f::Procurement.find(params[:id])
    end

    def errors
      @procurement.valid?
      @procurement.errors.full_messages
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
