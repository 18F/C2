module Whsc
  class ProposalsController < ApplicationController
    def new
      @proposal_form = Whsc::ProposalForm.new
    end

    def create
      @proposal_form = Whsc::ProposalForm.new(params[:whsc_proposal])
      if @proposal_form.valid?
        cart = Cart.new(
          flow: 'linear',
          name: @proposal_form.description
        )
        if cart.save
          cart.set_props(
            vendor: @proposal_form.vendor,
            amount: @proposal_form.amount
          )
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
