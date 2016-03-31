class ReportPolicy
  include ExceptionPolicy

  def initialize(user, record)
    super(user, record)
    @report = record
  end

  def can_show!
    check(can_show?, I18n.t("errors.policies.report.show_permission"))
  end

  def can_destroy!
    check(owner?, I18n.t("errors.policies.report.destroy_permission"))
  end

  def can_preview!
    can_show!
  end

  protected

  def can_show?
    owner? || shares_client?
  end

  def can_destroy?
    owner?
  end

  def owner?
    @user == @report.user
  end

  def shares_client?
    @report.shared && @user.client_slug == @report.user.client_slug
  end
end
