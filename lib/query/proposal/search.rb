module Query
  module Proposal
    class Search
      attr_reader :relation, :current_user, :params, :client_data_type, :response

      def initialize(args = {})
        @relation = args[:relation]
        @current_user = args[:current_user]
        @params = args[:params]
      end

      def execute(query)
        dsl = build_dsl(query)
        @response = Proposal.search( dsl )
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
          client_data_type: find_client_data_type
        )
      end

      def find_client_data_type

      end
    end
  end
end
