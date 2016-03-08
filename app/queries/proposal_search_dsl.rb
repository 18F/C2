require "elasticsearch/dsl"

class ProposalSearchDsl
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
    stringify_clauses [query_str, client_query].select(&:present?)
  end

  def humanized_query_string
    stringify_clauses [query_str, client_query_humanized].select(&:present?)
  end

  def client_query
    fielded = params[current_user.client_model_slug.to_sym]
    munge_fielded_params(fielded) if fielded
    ProposalFieldedSearchQuery.new(fielded)
  end

  private

  def stringify_clauses(clauses)
    if clauses.length == 2
      clauses.map { |c| "(#{c})" }.join(" AND ")
    elsif clauses.length == 1
      clauses[0].to_s
    else
      ""
    end
  end

  def client_query_humanized
    client_query.humanized(current_user.client_model)
  end

  def munge_fielded_params(fielded)
    if fielded[:created_at].present? && fielded[:created_within].present?
      convert_created_at_to_range(fielded)
    end
    if fielded[:includes_attachment].present?
      convert_includes_attachment(fielded)
      fielded.delete(:includes_attachment)
    end
    # do not calculate more than once, or when created_at is null
    fielded.delete(:created_within)
  end

  def convert_includes_attachment(fielded)
    fielded[:num_attachments] = ">0"
  end

  def convert_created_at_to_range(fielded)
    high_end_range = Time.zone.parse(fielded[:created_at])
    within_parsed = fielded[:created_within].match(/^(\d+) (\w+)/)
    return unless high_end_range && within_parsed
    low_end_range = high_end_range.utc - within_parsed[1].to_i.send(within_parsed[2])
    fielded[:created_at] = "[#{low_end_range.iso8601} TO #{high_end_range.utc.iso8601}]"
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
    calculate_from_size if params[:page]
    add_from
    add_size
  end

  def add_from
    if @from
      @dsl.from = @from
    elsif params[:from]
      @dsl.from = params[:from].to_i
    else
      @dsl.from = 0
    end
  end

  def add_size
    if params[:size] == :all
      @dsl.size = Proposal::MAX_DOWNLOAD_ROWS
    elsif @size
      @dsl.size = @size
    elsif params[:size]
      @dsl.size = params[:size].to_i
    else
      @dsl.size = Proposal::MAX_SEARCH_RESULTS
    end
  end

  def calculate_from_size
    page = params[:page].to_i
    @size ||= (params[:size] || Proposal::MAX_SEARCH_RESULTS).to_i
    @from = (page - 1) * @size.to_i
  end
end
