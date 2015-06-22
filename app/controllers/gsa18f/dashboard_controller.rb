module Gsa18f
  class DashboardController < ApplicationController
    before_filter :authenticate_user!
    
    def index
      @rows = self.format_results(self.queryset)
    end

    protected
    def queryset
      orm_query = Gsa18f::Procurement.
        joins(:proposal).
        merge(policy_scope(Proposal)).
        select('EXTRACT(YEAR FROM proposals.created_at) as year',
               'EXTRACT(MONTH FROM proposals.created_at) as month',
               'COUNT(*) as count',
               'SUM(cost_per_unit * quantity) as cost').
        group('year', 'month').
        order('year DESC', 'month DESC')
      # Convert the ORM into an array of hashes
      Gsa18f::Procurement.connection.select_all(orm_query)
    end

    def format_results(results)
      return_params = self.make_return_to("Dashboard", gsa18f_dashboard_path)
      results.map{|row|
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
