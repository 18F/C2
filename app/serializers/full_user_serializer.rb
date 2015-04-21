class FullUserSerializer < UserSerializer
  # make sure to keep docs/api.md up-to-date

  attributes(
    :first_name,
    :last_name,
    :email_address
  )
end
