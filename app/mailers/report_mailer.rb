class ReportMailer < ApplicationMailer
  add_template_helper ReportHelper

  def daily_budget_report
    @ba60_proposals = proposals_query("BA60")
    @ba61_proposals = proposals_query("BA61")
    @ba80_proposals = proposals_query("BA80")
    build_attachments

    mail(
      to: to_email,
      subject: "C2: Daily Budget report for #{date}",
      from: sender_email
    )
  end

  def weekly_fiscal_year_report(year)
    attachments["NCR_Work_Order_Report_FY#{year}.csv"] = Ncr::Reporter.new.build_fiscal_year_report_string(year)
    to_email = ENV.fetch("BUDGET_REPORT_RECIPIENT")

    mail(
      to: to_email,
      subject: "FY#{year} NCR Budget Report",
      body: "The annual report is attached to this email.",
      from: sender_email
    )
  end

  def scheduled_report(scheduled_report)
    attachments["#{scheduled_report.name}.csv"] = build_csv_report(scheduled_report.report)

    mail(
      to: email_to_user(scheduled_report.user),
      subject: "[C2 Report] #{scheduled_report.name}",
      body: "Your scheduled report is attached to this email."
      from: sender_email
    )
  end

  private

  def proposals_query(expense_type)
    Ncr::ExpenseTypeProposalsQuery.new(expense_type: expense_type, time_delimiter: 1.week.ago).find
  end

  def csv_reports
    {
      "approved-ba60-week" => @ba60_proposals,
      "approved-ba61-week" => @ba61_proposals,
      "approved-ba80-week" => @ba80_proposals,

      "pending-at-approving-official" => Ncr::Reporter.proposals_pending_approving_official,
      "pending-at-budget" => Ncr::Reporter.proposals_pending_budget,
      "pending-at-tier-one-approval" => Ncr::Reporter.proposals_tier_one_pending,
    }
  end

  def build_attachments
    date = Time.now.utc.strftime("%Y-%m-%d")
    csv_reports.each do |name, records|
      attachments[name + "-" + date + ".csv"] = Ncr::Reporter.as_csv(records)
    end
  end

  def to_email
    ENV.fetch("BUDGET_REPORT_RECIPIENT")
  end

  def date
    Time.now.utc.strftime("%a %m/%d/%y (%Z)")
  end

  def build_csv_report(report)
    proposal_data = report.run
    user = report.user
    csv_buf = ""
    csv_buf += CSV.generate_line( [ProposalDecorator.csv_headers, user.client_model.csv_headers].flatten ).chomp
    proposal_data.rows.each do |proposal|
      csv_buf += CSV.generate_line( proposal.decorate.as_csv ).chomp
    end
    csv_buf
  end
end
