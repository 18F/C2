module GsaPolicy
  def gsa_email?
    @user.email_address.end_with?('@gsa.gov')
  end

  def gsa!
    check(self.gsa_email?, "You must be logged in with a GSA email address to create")
  end

  def gsa_if_restricted!
    !self.restricted? || self.gsa!
  end
end
