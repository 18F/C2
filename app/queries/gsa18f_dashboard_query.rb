class Gsa18fDashboardQuery
  def initialize(user)
    @user = user
  end

  def select_all
    Gsa18f::Procurement.connection.select_all(query.to_sql)
  end

  private

  attr_reader :user

  def query
    Gsa18f::Procurement.
      joins(:proposal).
      merge(policy_scope).
      select(*select_fields).
      group("year", "month").
      order("year DESC", "month DESC")
  end

  def policy_scope
    ProposalPolicy::Scope.new(user, Proposal).resolve
  end

  def select_fields
    [
      "EXTRACT(YEAR FROM proposals.created_at) as year",
      "EXTRACT(MONTH FROM proposals.created_at) as month",
      "COUNT(*) as count",
      "SUM(cost_per_unit * quantity) as cost"
    ]
  end
end
