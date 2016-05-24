class HistoryList
  attr_reader :events

  def initialize(proposal)
    @proposal = proposal
    @events = make_events(ProposalVersionsQuery.new(proposal).container.query)
  end

  private

  def filter_versions(versions)
    versions.reject do |version|
      version_is_client_data?(version) ||
        version_is_ignored_type_creation?(version) ||
        version.item_type == "Step" #|| # TODO: What's creating these?
        # (version.event == "update" &&
        #   version.item_type == "Proposal") # TODO: include once they're properly formatted
    end
  end

  def version_is_client_data?(version)
    Proposal.client_model_names.include?(version.item_type)
  end

  def version_is_ignored_type_creation?(version)
    version.event == "create" &&
      !%w(Proposal Attachment Comment Observation Steps::Serial).include?(version.item_type)
  end

  def make_events(versions)
    filter_versions(versions).map do |version|
      HistoryEvent.new(version)
    end
  end
end
