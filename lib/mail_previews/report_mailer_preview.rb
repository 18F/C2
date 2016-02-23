class ReportMailerPreview < ActionMailer::Preview
  def daily_budget_report
    ENV["BUDGET_REPORT_RECIPIENT"] = "test@example.com"
    ReportMailer.daily_budget_report
  end
end
