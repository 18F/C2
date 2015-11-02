require "mail"
# usage:
# rake FY=2015 annual_ncr_report:annual_ncr_report

namespace :annual_ncr_report do
  desc "Emails FY approvals"
  task annual_ncr_report: :environment do
    ReportMailer.annual_ncr_report(ENV['FY'].to_i).deliver_now
    puts "Report has been sent!"
  end
end
