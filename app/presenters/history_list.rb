class HistoryList
  attr_reader :events

  def initialize(proposal)
    @proposal = proposal
    @events = make_events(ProposalVersionsQuery.new(proposal).container.query)
  end

  private

  def filter_versions(versions)
    versions.reject do |version|
      version.item_type == "Ncr::WorkOrder" ||
        version.item_type == "Gsa18f::Procurement" ||
        (version.event == "create" &&
          !%w(Proposal Attachment Comment Observation Steps::Serial).include?(version.item_type))
    end
  end

  def make_events(versions)
    filter_versions(versions).map do |version|
      HistoryEvent.new(version)
    end
  end
end
