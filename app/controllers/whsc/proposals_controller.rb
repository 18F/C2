module Whsc
  class ProposalsController < ApplicationController
    def new
      @proposal = Whsc::ProposalForm.new
    end
  end
end
