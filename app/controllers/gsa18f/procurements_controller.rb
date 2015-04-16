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
      @approver_email = @procurement.approver_email;
      if self.errors.empty?
        @procurement.save
        cart = @procurement.init_and_save_cart(
          @approver_email, current_user)
        flash[:success] = "Procurement submitted!"
        redirect_to cart_path(cart)
      else
        flash[:error] = errors
        render 'form'
      end
      # @form_url = {action: "create"}
      # @form_method = "post"
      # @proposal_form.requester = current_user
      # if @proposal_form.valid?
      #   cart = @proposal_form.create_cart
      #   if cart.persisted?
      #     flash[:success] = "Proposal submitted!"
      #     redirect_to cart_path(cart)
      #   else
      #     flash[:error] = cart.errors.full_messages
      #     render 'form'
      #   end
      # else
      #   flash[:error] = @proposal_form.errors.full_messages
      #   render 'form'
      # end
    end

    def edit
      @proposal_form = Gsa18f::Procurement.from_cart(self.cart)
      @form_url = {action: "update"}
      @form_method = "put"
      render 'form'
    end

    def update
      @proposal_form = Gsa18f::Procurement.new(params[:gsa18f_proposal])
      @form_url = {action: "update"}
      @form_method =  "put"
      @proposal_form.requester = current_user
      if @proposal_form.valid?
        @proposal_form.update_cart(self.cart)
        if not self.cart.errors.any?
          flash[:success] = "Proposal resubmitted!"
          redirect_to cart_path(self.cart)
        else
          flash[:error] = self.cart.errors.full_messages
          render 'form'
        end
      else
        flash[:error] = @proposal_form.errors.full_messages
        render 'form'
      end
    end

    def permitted_params
      fields = Gsa18f::Procurement.relevant_fields(
        params[:gsa18f_procurement][:recurring])
      params.require(:gsa18f_procurement).permit(:name, *fields)
    end

    protected
    def errors
      errors = []
      if !@procurement.valid?
        errors += @procurement.errors.full_messages
      end
      errors
    end

    def cart
      @cart ||= Cart.find(params[:id])
    end

    def redirect_if_cart_cant_be_edited
      if self.cart.approved?
        redirect_to new_gsa18f_proposal_path, :alert => "That proposal's already approved. New proposal?"
      elsif self.cart.requester != current_user
        redirect_to new_gsa18f_proposal_path, :alert => 'You cannot restart that proposal'
      end
    end
  end
end
