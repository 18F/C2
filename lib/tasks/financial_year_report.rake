require "mail"
# usage: 
# rake MAILTO=your.email@gsa.gov FY=15 financial_year_report:fy_report

namespace :financial_year_report do
	desc "Emails FY approvals"
	task :fy_report => :environment do
		proposals = Proposal.approved.where(client_data_type: "Ncr::WorkOrder")
		proposals = proposals.select {|p| p.client_data.fiscal_year == ENV['FY'].to_i}
		csv_string = CSV.generate do |csv|
			csv << ["Amount", "Date Approved", "Org Code", "CL#", 
				"Budget Activity", "SOC", "Function Code", "Building #", 
				"Vendor", "Description", "Requestor", "Approver"]
			for p in proposals
				csv << [p.client_data.amount, p.root_approval.approved_at, p.client_data.org_code, 
					p.client_data.cl_number, p.client_data.expense_type, p.client_data.soc_code, 
					p.client_data.function_code, p.client_data.building_number, p.client_data.vendor, 
					p.client_data.description, p.requester.full_name, p.client_data.approving_official.full_name]
			end
		end
		mail = Mail.new do
		  from     'c2admin@gmail.com'
		  to       ENV['MAILTO']
		  subject  'Annual Report of Approved Requests- 20' + ENV['FY']
		  body     'Report is attached to this email.'
		  add_file :filename => 'FY' + ENV['FY'] + '_Report.csv', :content => csv_string
		end
	
		mail.deliver
		puts "Report has been sent!"
	end
end