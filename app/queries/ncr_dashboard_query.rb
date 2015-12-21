class NcrDashboardQuery
  def initialize(user)
    @user = user
  end

  def select_all
    Ncr::WorkOrder.connection.select_all(query.to_sql)
  end

  private

  attr_reader :user

  def query
    Ncr::WorkOrder.
      joins(:proposal).
      merge(policy_scope).
      select(
        "EXTRACT(YEAR FROM proposals.created_at) as year",
        "EXTRACT(MONTH FROM proposals.created_at) as month",
        "COUNT(*) as count",
        "SUM(amount) as cost"
      ).
      group("year", "month").
      order("year DESC", "month DESC")
  end

  def policy_scope
    ProposalPolicy::Scope.new(user, Proposal).resolve
  end
end
