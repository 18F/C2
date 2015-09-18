class ReportMailer < ApplicationMailer
  add_template_helper ReportHelper

  def budget_status
    to_email = ENV.fetch('BUDGET_REPORT_RECIPIENT')
    date = Time.now.utc.strftime("%a %m/%d/%y (%Z)")

    build_attachments

    mail(
      to: to_email,
      subject: "C2: Daily Budget report for #{date}",
      from: self.sender_email
    )
  end

  private

  def self.csv_resports
    { 'approved-ba60-week' => Ncr::Reporter.as_csv(Ncr::Reporter.ba60_proposals),
      'approved-ba61-week' => Ncr::Reporter.as_csv(Ncr::Reporter.ba61_proposals),
      'approved-ba80-week' => Ncr::Reporter.as_csv(Ncr::Reporter.ba80_proposals),
      'pending-at-approving-official' => Ncr::Reporter.as_csv(Ncr::Reporter.proposals_pending_approving_official),
      'pending-at-budget' => Ncr::Reporter.as_csv(Ncr::Reporter.proposals_pending_budget),
      'pending-at-tier-one-approval' => Ncr::Reporter.as_csv(Ncr::Reporter.proposals_tier_one_pending),
    }
  end

  def build_attachments
    date = Time.now.utc.strftime('%Y-%m-%d')
    self.csv_reports.each do |name, csv|
      attachments[name + '-' + date + '.csv'] = csv
    end
  end
end
