class ApprovalSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :status
  )

  has_one :user
end
