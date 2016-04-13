class ProposalSearchSerializer < ActiveModel::Serializer
  attributes(
    :total,
    :proposals
  )

  def total
    object.es_response ? object.es_response.results.total : object.total
  end

  def proposals
    ActiveModel::ArraySerializer.new(object.rows, each_serializer: ProposalSerializer)
  end
end
