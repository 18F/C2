module Whsc
  class ProposalsController < ApplicationController
    before_filter :authenticate_user!

    def new
      @proposal_form = Whsc::ProposalForm.new
    end

    def create
      @proposal_form = Whsc::ProposalForm.new(params[:whsc_proposal])
      @proposal_form.requester = current_user
      if @proposal_form.valid?
        cart = @proposal_form.create_cart
        if cart.persisted?
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
