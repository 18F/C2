class ScheduledReportPolicy
  include ExceptionPolicy

  def initialize(user, record)
    super(user, record)
    @scheduled_report = record
  end

  def can_show!
    check(can_show?, I18n.t("errors.policies.scheduled_report.show_permission"))
  end

  def can_update!
    check(owner?, I18n.t("errors.policies.scheduled_report.update_permission"))
  end

  def can_destroy!
    check(owner?, I18n.t("errors.policies.scheduled_report.destroy_permission"))
  end

  protected

  def can_show?
    owner?
  end

  def can_destroy?
    owner?
  end

  def owner?
    @user == @scheduled_report.user
  end
end
