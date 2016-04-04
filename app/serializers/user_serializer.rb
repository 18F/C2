class UserSerializer < ActiveModel::Serializer
  # make sure to keep docs/api.md up-to-date

  attributes(
    :created_at,
    :id,
    :updated_at

    # leaving out personal info for now - see FullUserSerializer
  )

  def created_at
    object.created_at.utc
  end

  def updated_at
    object.updated_at.utc
  end
end
