module Query
  module Proposal
    class Search
      attr_reader :relation, :current_user, :params, :client_data_type, :response

      def initialize(args = {})
        @relation = args[:relation]
        @current_user = args[:current_user] or fail ":current_user required"
        @params = args[:params] || {}
      end

      def execute(query)
        dsl = build_dsl(query)
        @response = Proposal.search(dsl)
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
        if get_client_model_names.size != 1
          fail "Ambiguous client_model name detection from #{current_user.client_slug}"
        end
        get_client_model_names.first
      end

      def get_client_model_names
        client_namespace = current_user.client_slug.titleize
        class_names = client_namespace.to_sym.constants.select {|c| client_namespace.to_sym.const_get(c).is_a? Class}
        Proposal.CLIENT_MODELS & class_names
      end
    end
  end
end
