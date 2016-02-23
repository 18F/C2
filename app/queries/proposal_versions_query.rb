class ProposalVersionsQuery
  def initialize(proposal)
    @proposal = proposal
  end

  def container
    base_container.alter_query do |relation|
      relation.where(id: version_ids)
    end
  end

  private

  attr_reader :proposal

  def base_container
    @_base_container ||= TabularData::Container.new(:versions, container_config)
  end

  def version_ids
    @_version_ids ||= models.flat_map do |model|
      model.versions.pluck(:id)
    end
  end

  def models
    [
      proposal,
      proposal.client_data,
      proposal.steps,
      proposal.observations,
      proposal.comments.normal_comments,
      proposal.attachments
    ].flatten.compact
  end

  def container_config
    TabularData::ContainerConfig.new("versions", "default").settings
  end
end
