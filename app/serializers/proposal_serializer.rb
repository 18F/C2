class ProposalSerializer < ActiveModel::Serializer
  attributes(
    :created_at,
    :flow,
    :id,
    :status,
    :updated_at
  )

  # TODO has_one :requester
end
