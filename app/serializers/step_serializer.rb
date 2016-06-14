class StepSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :status,
    :completed_at,
    :type
  )

  has_one :user

  def completed_at
    object.completed_at.try(:utc)
  end
end
