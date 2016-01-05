require "elasticsearch/dsl"

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
          "(#{query_str}) AND (#{client_query.map { |k, v| "#{k}:(#{v})" }.join(' ')})"
        elsif client_query
          client_query.map { |k, v| "#{k}:(#{v})" }.join(" ")
        elsif query_str
          query_str
        end
      end

      private

      def client_query
        params[client_data_type.underscore.tr("/", "_").to_sym]
      end

      def build_dsl
        @dsl = Elasticsearch::DSL::Search::Search.new
        add_query
        add_filter
        add_sort
        add_pagination
      end

      def add_query
        searchdsl = self
        @dsl.query = Query.new
        @dsl.query do
          query_string do
            query searchdsl.composite_query_string
            default_operator searchdsl.default_operator
          end
        end
      end

      # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      def add_filter
        searchdsl = self
        @dsl.filter = Filter.new
        @dsl.filter do
          bool do
            if searchdsl.client_data_type.present?
              must do
                term client_data_type: searchdsl.client_data_type
              end
            end
            if searchdsl.apply_authz?
              must do
                term "subscribers.id" => searchdsl.current_user.id.to_s
              end
            end
          end
        end
      end
      # rubocop:enable

      def add_sort
        if params[:sort]
          @dsl.sort(params[:sort].map{ |pair| [pair.split(':')].to_h })
        end
      end

      def add_pagination
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
