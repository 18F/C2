module Ncr
  class DashboardController < ApplicationController
    before_filter :authenticate_user!
    
    def index
      queryset = Ncr::WorkOrder.
        joins(:proposal).
        merge(policy_scope(Proposal)).
        select('EXTRACT(YEAR FROM proposals.created_at) as year',
               'EXTRACT(MONTH FROM proposals.created_at) as month',
               'COUNT(*) as count',
               'SUM(amount) as cost').
        group('year', 'month').
        order('year DESC', 'month DESC')
      return_params = self.make_return_to("Dashboard", ncr_dashboard_path)
      @rows = Ncr::WorkOrder.connection.select_all(queryset).map{|row|
        start_date = Date.new(row["year"].to_i, row["month"].to_i, 1)
        end_date = start_date + 1.month
        {path: query_proposals_path(start_date: start_date.strftime(),
                                    end_date: end_date.strftime(),
                                    return_to: return_params),
         month: I18n.t("date.abbr_month_names")[start_date.month],
         year: start_date.year,
         count: row["count"].to_i,
         cost: row["cost"].to_f}
      }
    end
  end
end
