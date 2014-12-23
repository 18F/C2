module Whsc
  class ProposalsController < ApplicationController
    def new
      @proposal_form = Whsc::ProposalForm.new
    end

    def create
      form = Whsc::ProposalForm.new(params[:proposal_form])
      if form.valid?
        Cart.create!(
          flow: 'linear',
          name: form.description
        )
      end
      redirect_to new_whsc_proposal_path
    end
  end
end
