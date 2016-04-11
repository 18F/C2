module Api
  class ProposalsController < BaseController
    rescue_from ActiveRecord::RecordNotFound, with: :proposal_not_found_error

    before_action -> { authorize proposal }, only: [:show]

    def show
      render json: ProposalSerializer.new(proposal).to_json
    end

    def index
      listing = ProposalListingQuery.new(current_user, params)
      begin
        proposals = listing.query
        render json: ProposalSearchSerializer.new(proposals).to_json
      rescue SearchBadQuery, SearchUnavailable => error
        render json: { error: error.message }, status: 500
      end
    end    
 
    private

    def proposal_not_found_error
      render json: {
        message: "Proposal not found",
        error: "No proposal for id #{params[:id]}"
      }, status: 404
    end

    def proposal
      Proposal.find(params[:id])
    end
  end
end
