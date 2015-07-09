namespace :quick_report do
  desc "Output a budget report overview"
  task budget: :environment do

    total_proposals_last_week = Proposal.where(client_data_type: "Ncr::WorkOrder").where("created_at > ?",1.week.ago).count
    total_approved = Proposal.where(client_data_type: "Ncr::WorkOrder").where("created_at > ?",1.week.ago).where(status:'approved').count
    total_unapproved = Proposal.where(client_data_type: "Ncr::WorkOrder").where(status:'pending').count
    ba60_proposals = Proposal.where(status:'approved').where("created_at > ?",1.week.ago).where(client_data_type: "Ncr::WorkOrder").map(&:client_data).select{|d| d.expense_type == "BA60"};nil
    ba61_proposals = Proposal.where(status:'approved').where("created_at > ?",1.week.ago).where(client_data_type: "Ncr::WorkOrder").map(&:client_data).select{|d| d.expense_type == "BA61"}
    ba80_proposals = Proposal.where(status:'approved').where("created_at > ?",1.week.ago).where(client_data_type: "Ncr::WorkOrder").map(&:client_data).select{|d| d.expense_type == "BA80"};nil

    proposals_pending_approving_official = Proposal.where(client_data_type: "Ncr::WorkOrder").where(status: "pending").select{|p| p.approvals.pluck(:status)[0] == 'actionable'};nil
    proposals_pending_budget = Proposal.where(client_data_type: "Ncr::WorkOrder").where(status: "pending").select{|p| p.approvals.pluck(:status).last == 'actionable'}.sort{|a,b|a.client_data.expense_type <=> b.client_data.expense_type};nil

    puts "*"*50
    puts "LAST WEEK"
    puts "Number of requests: #{total_proposals_last_week}"
    puts "BA60 approved: #{ba60_proposals.count}"
    puts "BA61 approved: #{ba61_proposals.count}"
    puts "BA80 approved: #{ba80_proposals.count}"

    puts "\nTOTALS"
    puts "Total Requests pending: #{total_unapproved}"

    puts "\n====="
    puts "Approved ba60 requests last week:"
    puts "====="
    ba60_proposals.each{|wo| puts "#{wo.proposal.public_id} | Requester: #{wo.proposal.requester.email_address} | Budget Approver: #{wo.proposal.approvals.last.user_email_address} | Function code: #{wo.proposal.client_data.function_code} | Soc code: #{wo.proposal.client_data.soc_code}"};nil

    puts "\n====="
    puts "Approved ba61 requests: #{}"
    puts "====="
    ba61_proposals.each{|a| puts "#{a.proposal.public_id} | Requester: #{a.proposal.requester.email_address} | Budget Approver: #{a.proposal.approvals.last.user_email_address} | Function code: #{a.proposal.client_data.function_code} | Soc code: #{a.proposal.client_data.soc_code}"};nil

    puts "\n====="
    puts "Approved ba80 requests last week:"
    puts "====="
    ba80_proposals.each{|wo| puts "#{wo.proposal.public_id} | Requester: #{wo.proposal.requester.email_address} | Approver: #{wo.proposal.approvals.first.user_email_address} | Function code: #{wo.proposal.client_data.function_code} | Soc code: #{wo.proposal.client_data.soc_code}"};nil

    puts "\n====="
    puts "Total Pending at Approving Official: #{proposals_pending_approving_official.count}"
    puts "====="
    proposals_pending_approving_official.each{|p| puts "#{p.public_id} | Requester: #{p.requester.email_address} | Approver: #{p.approvals.first.user_email_address} | Created: #{p.created_at.in_time_zone('Eastern Time (US & Canada)')}"};nil

    puts "\n====="
    puts "Total Pending at Budget: #{proposals_pending_budget.count}"
    puts "====="
    proposals_pending_budget.each{|p| puts "#{p.public_id} | Requester: #{p.requester.email_address} | Approver: #{p.approvals.last.user_email_address} | Created: #{p.created_at.in_time_zone('Eastern Time (US & Canada)')}"};nil
    puts "*"*50

    #TODO:
    # send it in an email
    #
  end
end
