class ProposalSearchSerializer < ActiveModel::Serializer
  attributes(
    :current_page,
    :from,
    :proposals,
    :size,
    :total
  )

  def size
    object.size
  end

  def from
    object.from
  end

  def current_page
    object.current_page
  end

  def total
    object.es_response ? object.es_response.results.total : object.total
  end

  def proposals
    ActiveModel::ArraySerializer.new(object.rows, each_serializer: ProposalSerializer)
  end
end
