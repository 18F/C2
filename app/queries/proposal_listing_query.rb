class ProposalListingQuery
  attr_reader :params, :relation, :user

  def initialize(user, params, proposals = Proposal.all)
    @params = params
    @relation = proposals
    @user = user
  end

  def all
    index_visible_container(:all)
  end

  def pending
    index_visible_container(:pending, filter: pending_filter).alter_query(&:pending)
  end

  def pending_review
    index_visible_container(:pending_review, filter: pending_review_filter).alter_query(&:pending)
  end

  def completed
    index_visible_container(:completed).alter_query(&:completed)
  end

  def canceled
    index_visible_container(:canceled).alter_query(&:canceled)
  end

  def closed
    proposals_container(:closed).alter_query(&:closed)
  end

  def start_date
    @start_date ||= param_date(:start_date)
  end

  def end_date
    @end_date ||= param_date(:end_date)
  end

  def query
    proposals_data = query_container
    apply_paging_filter(proposals_data)
    apply_date_filters(proposals_data)
    apply_text_filter(proposals_data)
    apply_status_filter(proposals_data)
    proposals_data
  end

  protected

  def pending_filter
    proc do |proposals|
      proposals.select { |proposal| !proposal.awaiting_step_user?(user) }
    end
  end

  def pending_review_filter
    proc do |proposals|
      proposals.select { |proposal| proposal.awaiting_step_user?(user) }
    end
  end

  def proposals_container(name, extra_config = {})
    config = TabularData::ContainerConfig.new("proposals", user.client_slug).settings
    config = config.merge(extra_config)
    container = TabularData::Container.new(name, config)

    container.alter_query do |proposal|
      ProposalPolicy::Scope.new(user, proposal).resolve.includes(:client_data)
    end
    container.state_from_params = params

    container
  end

  # returns a Container that is limited to what the user should see on /proposals, even if the ProposalPolicy::Scope allows them to see more
  def index_visible_container(name, config = {})
    container = proposals_container(name, config)

    container.alter_query do |rel|
      condition = ProposalClausesQuery.new.which_involve(user)
      rel.where(condition)
    end
  end

  def param_date(sym)
    begin
      Date.strptime(params[sym].to_s)
    rescue ArgumentError
      nil
    end
  end

  def query_container
    if params[:text]
      # only sort by the match priority if searching
      proposals_container(:query, frozen_sort: true)
    else
      proposals_container(:query)
    end
  end

  def apply_date_filters(proposals_data)
    if start_date
      proposals_data.alter_query { |proposal| proposal.where("proposals.created_at >= ?", start_date) }
    end

    if end_date
      proposals_data.alter_query { |proposal| proposal.where("proposals.created_at < ?", end_date) }
    end
  end

  def apply_text_filter(proposals_data)
    if params[:text] || params[user.client_model_slug.to_sym]
      proposals_data.alter_query do |proposal|
        searcher = build_text_searcher(proposal)
        proposals = searcher.execute(params[:text])
        proposals_data.es_response = searcher.response
        proposals
      end
    end
  end

  def apply_paging_filter(proposals_data)
    unless params[:text] || params[user.client_model_slug.to_sym]
      limit = proposal_limits
      offset = calculate_offset(limit)
      proposals_data.alter_query { |proposal| proposal.limit(limit).offset(offset) }
    end
  end

  def proposal_limits
    limit = (params[:size] || Proposal::MAX_SEARCH_RESULTS)
    if limit == :all
      limit = Proposal.all.length
    end
    limit.to_i
  end

  def calculate_offset(limit)
    if params[:page]
      (params[:page].to_i - 1) * limit
    else
      (params[:from] || 0).to_i
    end
  end

  def build_text_searcher(proposal)
    ProposalSearchQuery.new(
      current_user: user,
      relation: proposal,
      params: params
    )
  end

  def apply_status_filter(proposals_data)
    if params[:status]
      proposals_data.alter_query { |proposal| proposal.where(status: params[:status]) }
    end
  end
end
