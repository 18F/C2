module Query
  module Proposal
    class Search
      attr_reader :relation, :current_user, :params, :client_data_type, :response

      def initialize(args)
        puts args.pretty_inspect
        @relation = args[:relation]
        @current_user = args[:current_user] or fail ":current_user required"
        @params = args[:params] || {}
      end

      def execute(query)
        dsl = build_dsl(query)
        @response = ::Proposal.search(dsl)
        if relation
          @response.records.merge(relation)
        else
          @response.records
        end
      end

      private

      def build_dsl(query)
        dsl = Query::Proposal::SearchDSL.new(
          params: params, 
          current_user: current_user, 
          query: query,
          client_data_type: ::Proposal.client_model_for(current_user).to_s
        )
      end
    end
  end
end
