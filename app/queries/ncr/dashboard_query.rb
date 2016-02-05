module Ncr
  class DashboardQuery < ::DashboardQuery
    def select_all
      Ncr::WorkOrder.connection.select_all(query.to_sql)
    end

    private

    def query
      Ncr::WorkOrder.
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
        "SUM(amount) as cost"
      ]
    end
  end
end
