module Ncr
  class ProposalsController < ApplicationController
    before_filter :authenticate_user!

    def new
      @proposal_form = Ncr::ProposalForm.new
      approver = self.suggested_approver
      if approver
        @proposal_form.approver_email = approver.email_address
      end
    end

    def create
      @proposal_form = Ncr::ProposalForm.new(params[:ncr_proposal])
      @proposal_form.requester = current_user
      if @proposal_form.valid?
        cart = @proposal_form.create_cart
        if cart.persisted?
          Dispatcher.deliver_new_cart_emails(cart)
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
