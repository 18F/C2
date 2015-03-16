module Gsa18f
  class ProposalsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :redirect_if_cart_cant_be_edited, only: [:edit, :update]

    def new
      @proposal_form = Gsa18f::ProposalForm.new
      @form_url = {action: "create"}
      @form_method = "post"
      approver = self.suggested_approver
      # if approver
      #   @proposal_form.approver_email = approver.email_address
      # end
      render 'form'
    end

    def create
      @proposal_form = Gsa18f::ProposalForm.new(params[:gsa18f_proposal])
      @form_url = {action: "create"}
      @form_method = "post"
      @proposal_form.requester = current_user
      if @proposal_form.valid?
        cart = @proposal_form.create_cart
        if cart.persisted?
          flash[:success] = "Proposal submitted!"
          redirect_to cart_path(cart)
        else
          flash[:error] = cart.errors.full_messages
          render 'form'
        end
      else
        flash[:error] = @proposal_form.errors.full_messages
        render 'form'
      end
    end

    def edit
      @proposal_form = Gsa18f::ProposalForm.from_cart(self.cart)
      @form_url = {action: "update"}
      @form_method = "put"
      render 'form'
    end

    def update
      @proposal_form = Gsa18f::ProposalForm.new(params[:gsa18f_proposal])
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

    protected

    def last_cart
      current_user.last_requested_cart
    end

    def last_approvers
      last_cart.try(:approvers)
    end

    def suggested_approver
      last_approvers.try(:first)
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
