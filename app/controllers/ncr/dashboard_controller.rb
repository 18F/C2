module Ncr
  class DashboardController < ApplicationController
    before_filter :authenticate_user!
    
    def index
      queryset = Ncr::WorkOrder.select(
        'EXTRACT(YEAR FROM ncr_work_orders.created_at) as year',
        'EXTRACT(MONTH FROM ncr_work_orders.created_at) as month',
        'COUNT(*) as count',
        'SUM(amount) as cost'
      )
      queryset = queryset.group('year', 'month')
                         .order('year DESC', 'month DESC')
                         .joins(:proposal).merge(policy_scope(Proposal))
      @rows = Ncr::WorkOrder.connection.select_all(queryset).map{|row|
        start_date = Date.new(row["year"].to_i, row["month"].to_i, 1)
        end_date = start_date + 1.month
        {path: query_proposals_path(
            start_date: start_date.strftime(),
            end_date: end_date.strftime(),
            back_to: {path: ncr_dashboard_path, name: "Dashboard"}),
         month: I18n.t("date.abbr_month_names")[start_date.month],
         year: start_date.year,
         row: row["count"],
         const: row["cost"]}
      }
    end
  end
end
