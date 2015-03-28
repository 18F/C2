class ProposalSerializer < ActiveModel::Serializer
  attributes(
    :created_at,
    :flow,
    :id,
    :status,
    :updated_at
  )

  has_one :requester
end
