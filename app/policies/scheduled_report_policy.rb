class ScheduledReportPolicy
  include ExceptionPolicy

  def initialize(user, record)
    super(user, record)
    @scheduled_report = record
  end

  def can_show!
    check(can_show?, "You are not allowed to view this Scheduled Report.")
  end

  def can_update!
    check(owner?, "You are not allowed to update this Scheduled Report.")
  end

  def can_destroy!
    check(owner?, "You are not allowed to delete this Scheduled Report.")
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
