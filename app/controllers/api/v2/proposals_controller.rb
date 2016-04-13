module Api
  module V2
    class ProposalsController < BaseController
      rescue_from ActiveRecord::RecordNotFound, with: :proposal_not_found_error
      rescue_from ClientModelMismatch, with: :auth_errors

      before_action -> { authorize proposal }, only: [:update, :show]

      def create
        if proposal = create_proposal
          DispatchFinder.run(proposal).deliver_new_proposal_emails
          render json: ProposalSerializer.new(proposal).to_json
        else
          render json: {
            errors: errors,
            message: "Failed to create proposal"
          }, status: 400
        end
      end

      def update
        if update_proposal
          render json: ProposalSerializer.new(proposal).to_json
        else
          render json: {
            errors: errors,
            message: "Failed to update proposal"
          }, status: 400
        end
      end

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

      def check_client_model
        unless params.fetch(current_user.client_model_slug, false)
          raise ClientModelMismatch, "Invalid client model"
        end
      end

      def create_proposal
        check_client_model
        @client_data_instance = create_client_data_instance
        @client_data_instance.build_proposal(requester: current_user)
        if errors.empty?
          proposal = ClientDataCreator.new(@client_data_instance, current_user, attachment_params).run
          @client_data_instance.initialize_steps
          proposal
        else
          false
        end
      end

      def update_client_data_instance
        @client_data_instance = proposal.client_data
        client_model_class = @client_data_instance.class
        @client_data_instance.assign_attributes(client_model_class.permitted_params(params, @client_data_instance))
      end

      def update_proposal
        update_client_data_instance
        if errors.any?
          false
        else
          comment = ProposalUpdateRecorder.new(@client_data_instance, current_user).run
          @client_data_instance.save
          @client_data_instance.setup_and_email_subscribers(comment)
          proposal.reload
        end
      end

      def create_client_data_instance
        client_model_class = current_user.client_model
        client_model_class.new(client_model_class.permitted_params(params, nil))
      end

      def errors
        @client_data_instance.validate
        @client_data_instance.errors.full_messages
      end

      def proposal_not_found_error
        render json: {
          message: "Proposal not found",
          error: "No proposal for id #{params[:id]}"
        }, status: 404
      end

      def proposal
        Proposal.find(params[:id])
      end

      def attachment_params
        params.permit(attachments: [])[:attachments] || []
      end
    end
  end
end
