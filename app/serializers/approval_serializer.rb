class ApprovalSerializer < ActiveModel::Serializer
  # make sure to keep docs/api.md up-to-date

  attributes(
    :id,
    :status
  )

  has_one :user
  # TODO updated_at, as a proxy for when it was approved
end
