class ProposalSearchSerializer < ActiveModel::Serializer
  delegate :current_page, :from, :size, to: :object

  attributes(
    :current_page,
    :from,
    :proposals,
    :size,
    :total
  )

  def total
    object.es_response ? object.es_response.results.total : object.total
  end

  def proposals
    ActiveModel::ArraySerializer.new(object.rows, each_serializer: ProposalSerializer)
  end
end
