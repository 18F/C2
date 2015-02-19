module Ncr
  class ProposalsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :not_approved, only: [:edit, :update]
    before_filter :cart_owner, only: [:edit, :update]

    def new
      @proposal_form = Ncr::ProposalForm.new
      @form_url, @form_method = {action: "create"}, "post"
      approver = self.suggested_approver
      if approver
        @proposal_form.approver_email = approver.email_address
      end
    end

    def create
      @proposal_form = Ncr::ProposalForm.new(params[:ncr_proposal])
      @form_url, @form_method = {action: "create"}, "post"
      @proposal_form.requester = current_user
      if @proposal_form.valid?
        cart = @proposal_form.create_cart
        if cart.persisted?
          flash[:success] = "Proposal submitted!"
          redirect_to cart_path(cart)
        else
          flash[:error] = cart.errors.full_messages
          render 'new'
        end
      else
        flash[:error] = @proposal_form.errors.full_messages
        render 'new'
      end
    end

    def not_approved
      cart = Cart.find(params[:id])
      if cart.approved?
        redirect_to new_ncr_proposal_path, :alert => "That proposal's already approved. New proposal?"
      end
    end
    def cart_owner
      cart = Cart.find(params[:id])
      if cart.requester != current_user
        redirect_to new_ncr_proposal_path, :alert => 'You cannot restart that proposal'
      end
    end

    def edit
      cart = Cart.find(params[:id])
      @proposal_form = Ncr::ProposalForm.from_cart(cart)
      @form_url, @form_method = {action: "update"}, "put"
      render 'new'
    end

    def update
      cart = Cart.find(params[:id])
      @proposal_form = Ncr::ProposalForm.new(params[:ncr_proposal])
      @form_url, @form_method = {action: "update"}, "put"
      @proposal_form.requester = current_user
      if @proposal_form.valid?
        @proposal_form.update_cart(cart)
        if cart.persisted?
          flash[:success] = "Proposal resubmitted!"
          redirect_to cart_path(cart)
        else
          flash[:error] = cart.errors.full_messages
          render 'new'
        end
      else
        flash[:error] = @proposal_form.errors.full_messages
        render 'new'
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
  end
end
