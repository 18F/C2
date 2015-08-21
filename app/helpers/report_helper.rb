module ReportHelper
  def pretty_date(date)
    date.in_time_zone('Eastern Time (US & Canada)').strftime("%a %m/%d/%y")
  end

  def budget_proposals(type, timespan)
    Proposal.approved.where(client_data_type: "Ncr::WorkOrder")
    .where("created_at > ?", timespan)
    .map(&:client_data).select{|d| d.expense_type == type}
  end
end
