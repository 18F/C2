module GsaPolicy
  GSA_DOMAIN = "@gsa.gov"

  def gsa_email?
    @user.email_address.end_with?(GSA_DOMAIN)
  end

  def gsa!
    check(gsa_email?, I18n.t("errors.policies.gsa.gsa_email_required"))
  end

  def gsa_if_restricted!
    !restricted? || gsa!
  end
end
