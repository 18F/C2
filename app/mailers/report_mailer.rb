class ReportMailer < ApplicationMailer
  add_template_helper ReportHelper

  def budget_status
    to_email = ENV.fetch('BUDGET_REPORT_RECIPIENT')
    date = Time.now.utc.strftime("%a %m/%d/%y (%Z)")

    mail(
      to: to_email,
      subject: "C2: Daily Budget report for #{date}",
      from: self.sender_email
    )
  end
end
