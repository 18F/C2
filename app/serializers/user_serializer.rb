class UserSerializer < ActiveModel::Serializer
  # make sure to keep docs/api.md up-to-date

  attributes(
    :created_at,
    :id,
    :updated_at

    # leaving out personal info for now - see FullUserSerializer
  )
end
