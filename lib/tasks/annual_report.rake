require "mail"
# usage: 
# rake MAILTO=your.email@gsa.gov FY=15 annual_report:annual_report

namespace :annual_report do
	desc "Emails FY approvals"
	task :annual_report => :environment do
		ReportMailer.annual_report(ENV['FY'].to_i, ENV['MAILTO']).deliver_later

		puts "Report has been sent!"
	end
end