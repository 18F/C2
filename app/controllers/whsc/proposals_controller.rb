module Whsc
  class ProposalsController < ApplicationController
    def new
      @proposal_form = Whsc::ProposalForm.new
    end

    def create
      form = Whsc::ProposalForm.new(params[:whsc_proposal])
      if form.valid?
        cart = Cart.create!(
          flow: 'linear',
          name: form.description
        )
        cart.set_props(
          vendor: form.vendor,
          amount: form.amount
        )
      end
      redirect_to new_whsc_proposal_path
    end
  end
end
