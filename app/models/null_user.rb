class NullUser
  def first_name
    "Unknown"
  end

  def last_name
    "User"
  end

  def email_address
    "unknownuser@example.com"
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
