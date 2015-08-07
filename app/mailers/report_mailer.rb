class ReportMailer < ActionMailer::Base
  add_template_helper ReportHelper

  def budget_status
    to_email = ENV.fetch('BUDGET_REPORT_RECIPIENT')

    @total_last_week = Ncr::Reporter.total_last_week
    @total_unapproved = Ncr::Reporter.total_unapproved

    @ba60_proposals = Ncr::Reporter.ba60_proposals
    @ba61_proposals = Ncr::Reporter.ba61_proposals
    @ba80_proposals = Ncr::Reporter.ba80_proposals

    @proposals_pending_approving_official = Ncr::Reporter.proposals_pending_approving_official
    @proposals_pending_budget = Ncr::Reporter.proposals_pending_budget

    date = Time.now.in_time_zone('Eastern Time (US & Canada)').strftime("%a %m/%d/%y")

    mail(
      to: to_email,
      subject: "C2: Daily Budget report for #{date}",
      from: sender_email
    )
  end


  private

  def sender_email
    ENV['NOTIFICATION_FROM_EMAIL'] || 'noreply@some.gov'
  end
end
