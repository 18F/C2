module ReportHelper
  def pretty_date(date)
    date.strftime("%a %m/%d/%y (%Z)")
  end

  def budget_proposals(type, timespan)
    Proposal.approved.where(client_data_type: "Ncr::WorkOrder")
    .where("created_at > ?", timespan)
    .map(&:client_data).select{|d| d.expense_type == type}
  end
end
