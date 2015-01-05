module Whsc
  class ProposalsController < ApplicationController
    before_filter :authenticate_user!

    def new
      @proposal_form = Whsc::ProposalForm.new
      last_cart = current_user.last_requested_cart
      if last_cart
        approver = last_cart.approvers.first
        @proposal_form.approver_email = approver.try(:email_address)
      end
    end

    def create
      @proposal_form = Whsc::ProposalForm.new(params[:whsc_proposal])
      @proposal_form.requester = current_user
      if @proposal_form.valid?
        cart = @proposal_form.create_cart
        if cart.persisted?
          Dispatcher.deliver_new_cart_emails(cart)
          flash[:success] = "Proposal submitted!"
          redirect_to new_whsc_proposal_path
        else
          flash[:error] = cart.errors.full_messages
          render 'new'
        end
      else
        flash[:error] = @proposal_form.errors.full_messages
        render 'new'
      end
    end
  end
end
