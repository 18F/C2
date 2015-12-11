require 'elasticsearch/dsl'

module Query
  module Proposal
    class SearchDSL
      include Elasticsearch::DSL

      attr_reader :params, :current_user, :query_str, :client_data_type

      def initialize(args)
        @query_str = args[:query] or fail ":query required"
        @client_data_type = args[:client_data_type] or fail ":client_data_type required"
        @current_user = args[:current_user]
        @params = args[:params]
        build_dsl
      end

      def to_hash
        @dsl.to_hash
      end

      def default_operator
        params[:operator] || "and"
      end

      def apply_authz?
        current_user && !current_user.admin? && !current_user.client_admin?
      end

      def composite_query_string
        if client_query && query_str
          "(#{query_str}) AND (#{client_query.map{|k,v| "#{k}:#{v}"}.join(' ')})"
        elsif client_query
          client_query.map{|k,v| "#{k}:#{v}"}.join(' ')
        elsif query_str
          query_str
        end 
      end

      private

      def client_query
        params[client_data_type.underscore.gsub('/', '_').to_sym]
      end

      def build_dsl
        searchdsl = self
        @dsl = Elasticsearch::DSL::Search::Search.new
        @dsl.query = Queries::Filtered.new
        @dsl.query.query do
          match do
            query searchdsl.composite_query_string
            operator searchdsl.default_operator
          end
        end
        @dsl.query.filter do
          term client_data_type: searchdsl.client_data_type
          if searchdsl.apply_authz?
            term subscribers: searchdsl.current_user.id.to_s
          end
        end

        if params[:sort]
          @dsl.sort = params[:sort]
        end
        if params[:from]
          @dsl.from = params[:from].to_i
        end
        if params[:size]
          @dsl.size = params[:size].to_i
        end 
      end
    end
  end
end
