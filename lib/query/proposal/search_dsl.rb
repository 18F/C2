require "elasticsearch/dsl"

module Query
  module Proposal
    class SearchDSL
      include Elasticsearch::DSL

      attr_reader :params, :current_user, :query_str, :client_data_type

      def initialize(args)
        @query_str = args[:query]
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
        if client_query.present? && query_str.present?
          "(#{query_str}) AND (#{client_query})"
        elsif client_query.present?
          client_query.to_s
        elsif query_str.present?
          query_str.to_s
        else
          ""
        end
      end

      def client_query
        fielded = params[current_user.client_model_slug.to_sym]
        munge_fielded_params(fielded) if fielded
        FieldedSearch.new(fielded)
      end

      private

      def munge_fielded_params(fielded)
        if fielded[:created_at].present? && fielded[:created_within].present?
          convert_created_at_to_range(fielded)
        end
        # do not calculate more than once, or when created_at is null
        fielded.delete(:created_within)
      end

      def convert_created_at_to_range(fielded)
        high_end_range = Time.zone.parse(fielded[:created_at])
        within_parsed = fielded[:created_within].match(/^(\d+) (\w+)/)
        return unless high_end_range && within_parsed
        low_end_range = high_end_range.utc - within_parsed[1].to_i.send(within_parsed[2])
        fielded[:created_at] = "[#{low_end_range} TO #{high_end_range.utc}]"
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

      def add_filter
        bools = build_filters

        if bools.any?
          @dsl.filter = Filter.new
          @dsl.filter.bool do
            bools.each do |must_filter|
              filter_block = must_filter.instance_variable_get(:@block)
              must(&filter_block)
            end
          end
        end
      end

      def build_filters
        bools = []
        if client_data_type.present?
          bools.push client_data_filter
        end
        if apply_authz?
          bools.push authz_filter
        end
        bools
      end

      def client_data_filter
        searchdsl = self
        Filter.new do
          term client_data_type: searchdsl.client_data_type
        end
      end

      def authz_filter
        searchdsl = self
        Filter.new do
          term "subscribers.id" => searchdsl.current_user.id.to_s
        end
      end

      def add_sort
        if params[:sort]
          @dsl.sort(params[:sort].map { |pair| [pair.split(":")].to_h })
        end
      end

      def add_pagination
        if params[:from]
          @dsl.from = params[:from].to_i
        else
          @dsl.from = 0
        end
        if params[:size]
          @dsl.size = params[:size].to_i
        else
          @dsl.size = ::Proposal::MAX_SEARCH_RESULTS
        end
      end
    end
  end
end
