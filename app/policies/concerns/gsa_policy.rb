module GsaPolicy
  GSA_DOMAIN = "@gsa.gov"

  def gsa_email?
    @user.email_address.end_with?(GSA_DOMAIN)
  end

  def gsa!
    check(gsa_email?, "You must be logged in with a GSA email address to create")
  end

  def gsa_if_restricted!
    !restricted? || gsa!
  end
end
