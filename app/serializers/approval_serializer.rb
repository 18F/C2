class ApprovalSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :status
  )

  has_one :user
  # TODO updated_at, as a proxy for when it was approved
end
