class ReportPolicy
  include ExceptionPolicy

  def initialize(user, record)
    super(user, record)
    @report = record
  end

  def can_show!
    check(can_show?, "You are not allowed to view this Report.")
  end

  def can_destroy!
    check(owner?, "You are not allowed to delete this Report.")
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
