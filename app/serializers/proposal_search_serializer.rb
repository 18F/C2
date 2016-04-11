class ProposalSearchSerializer < ActiveModel::Serializer
  attributes(
    :total,
    :proposals
  )

  def total
    object.es_response ? object.es_response.results.total : object.rows.to_a.size
  end

  def proposals
    ActiveModel::ArraySerializer.new(object.rows.to_a, each_serializer: ProposalSerializer)
  end
end
