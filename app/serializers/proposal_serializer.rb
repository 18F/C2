class ProposalSerializer < ActiveModel::Serializer
  # make sure to keep docs/api.md up-to-date

  attributes(
    :created_at,
    :flow,
    :id,
    :status,
    :updated_at
  )

  has_one :requester
  has_many :individual_steps, root: :steps
end
