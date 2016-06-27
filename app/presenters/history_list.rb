class HistoryList
  attr_reader :events

  def initialize(proposal)
    @proposal = proposal
    @events = make_events(ProposalVersionsQuery.new(proposal).container.query)
    add_deleted_attachments
  end

  def filtered_approvals
    @events.reject! do |event|
      event.item_type == "Steps::Approval" &&
        event.object.include?("status: actionable")
    end
    @events
  end

  private

  def filter_versions(versions)
    versions.reject do |version|
      version_is_ignored_type_creation?(version) ||
        version_is_proposal_update?(version) ||
        version.item_type == "Step" # TODO: What's creating these?
    end
  end

  def version_is_client_data?(version)
    Proposal.client_model_names.include?(version.item_type)
  end

  def version_is_proposal_update?(version)
    (version.event == "update" &&
      version.item_type == "Proposal")
  end

  def version_is_ignored_type_creation?(version)
    version.event == "create" &&
      !%w(Proposal Attachment Comment Observation Steps::Serial).include?(version.item_type)
  end

  def add_deleted_attachments
    attachments = deleted_attachments
    unless attachments.empty?
      @events += attachments
      @events.sort_by!(&:created_at)
    end
  end

  def deleted_attachments
    PaperTrail::Version.
      where(event: "destroy", item_type: "Attachment").
      where_object(proposal_id: @proposal.id).map do |version|
        HistoryEvent.new(version)
      end
  end

  def make_events(versions)
    events = filter_versions(versions).map do |version|
      HistoryEvent.new(version)
    end
    events
  end
end
