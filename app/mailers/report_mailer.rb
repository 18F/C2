class ReportMailer < ActionMailer::Base
  add_template_helper ReportHelper

  def budget_status
    to_email = ENV.fetch('BUDGET_REPORT_RECIPIENT')
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
