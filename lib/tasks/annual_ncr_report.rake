require "mail"
# usage:
# rake MAILTO=your.email@gsa.gov FY=2015 annual_ncr_report:annual_ncr_report

namespace :annual_ncr_report do
  desc "Emails FY approvals"
  task annual_ncr_report: :environment do
    ReportMailer.annual_ncr_report(ENV['FY'].to_i, ENV['MAILTO']).deliver_later
    puts "Report has been sent!"
  end
end
