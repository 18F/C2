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

      def humanized_query_string
        if client_query.present? && query_str.present?
          "(#{query_str}) AND (#{client_query.humanized(current_user.client_model).to_s})"
        elsif client_query.present?
          client_query.humanized(current_user.client_model).to_s
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
          munge_created_at_field(fielded)
        end
        # do not calculate more than once, or when created_at is null
        fielded.delete(:created_within)
      end

      def munge_created_at_field(fielded)
        high_end_range = Time.zone.parse(fielded[:created_at])
        within_parsed = fielded[:created_within].match(/^(\d+) (\w+)/)
        return unless high_end_range && within_parsed
        low_end_range = high_end_range.utc - within_parsed[1].to_i.send(within_parsed[2])
        fielded[:created_at] = "[#{low_end_range} TO #{high_end_range.utc}]"
      end

      def build_dsl
        @dsl = Elasticsearch::DSL::Search::Search.new
        # we only need primary key. this cuts down response time by ~70%.
        @dsl.source(["id"])
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
          @dsl.sort = params[:sort]
        end
      end

      def add_pagination
        return if params[:size] == :all
        calculate_from_size if params[:page]
        add_from
        add_size
      end

      def add_from
        if @from
          @dsl.from = @from
        elsif params[:from]
          @dsl.from = params[:from]
        else
          @dsl.from = 0
        end
      end

      def add_size
        if @size
          @dsl.size = @size
        elsif params[:size]
          @dsl.size = params[:size]
        else
          @dsl.size = ::Proposal::MAX_SEARCH_RESULTS
        end
      end

      def calculate_from_size
        page = params[:page].to_i
        @size ||= params[:size] || ::Proposal::MAX_SEARCH_RESULTS
        @from = (page - 1) * @size.to_i
      end
    end
  end
end
