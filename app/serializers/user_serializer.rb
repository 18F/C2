class UserSerializer < ActiveModel::Serializer
  attributes(
    :created_at,
    :id,
    :updated_at

    # leaving out personal info for now
    # :first_name,
    # :last_name,
    # :email_address
  )
end
