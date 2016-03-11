class ProposalSearchQuery
  attr_reader :relation, :current_user, :params, :response, :dsl

  def initialize(args)
    @relation = args[:relation]
    @current_user = args[:current_user] or fail ":current_user required"
    @params = args[:params] || {}
  end

  def execute(query)
    build_dsl(query)
    @response = Proposal.search(dsl)
    begin
      if relation
        @response.records.merge(relation).to_a
      else
        @response.records.to_a
      end
    rescue Elasticsearch::Transport::Transport::ServerError => _error
      raise SearchUnavailable, I18n.t("errors.features.es.service_unavailable")
    rescue Faraday::ConnectionFailed => _error
      raise SearchUnavailable, I18n.t("errors.features.es.service_unavailable")
    end
  end

  private

  def build_dsl(query)
    @dsl = ProposalSearchDsl.new(
      params: params,
      current_user: current_user,
      query: query,
      client_data_type: current_user.client_model.to_s
    )
  end
end
