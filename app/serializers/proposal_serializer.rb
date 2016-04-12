class ProposalSerializer < ActiveModel::Serializer
  # make sure to keep docs/api.md up-to-date

  attributes(
    :created_at,
    :id,
    :status,
    :updated_at,
    :client_data_type
  )

  has_one :client_data
  has_one :requester
  has_many :individual_steps, root: :steps

  def created_at
    object.created_at.utc
  end

  def updated_at
    object.updated_at.utc
  end
end
