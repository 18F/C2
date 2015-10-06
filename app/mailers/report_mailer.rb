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

  def annual_report(year, to_email)
    proposals = Proposal.approved.where(client_data_type: "Ncr::WorkOrder")
        proposals = proposals.select {|p| p.client_data.fiscal_year == year}
        csv_string = CSV.generate do |csv|
          csv << ["Amount", "Date Approved", "Org Code", "CL#", 
            "Budget Activity", "SOC", "Function Code", "Building #", 
            "Vendor", "Description", "Requestor", "Approver"]
          for p in proposals
            approver_name = p.client_data.approving_official ? p.client_data.approving_official.full_name : "no approver listed"
            csv << [p.client_data.amount, p.root_approval.approved_at, p.client_data.org_code, 
              p.client_data.cl_number, p.client_data.expense_type, p.client_data.soc_code, 
              p.client_data.function_code, p.client_data.building_number, p.client_data.vendor, 
              p.client_data.description, p.requester.full_name, approver_name]
          end
        end

      attachments['FY' + year.to_s + '_Report.csv'] = csv_string

      mail(
        to: to_email,
        subject: 'FY' + year.to_s + ' Report',
        body: 'The annual report is attached to this email.',
        from: self.sender_email
      )
  end

  private

  def csv_reports
    { 'approved-ba60-week' => Ncr::Reporter.ba60_proposals,
      'approved-ba61-week' => Ncr::Reporter.ba61_proposals,
      'approved-ba80-week' => Ncr::Reporter.ba80_proposals,
      'pending-at-approving-official' => Ncr::Reporter.proposals_pending_approving_official,
      'pending-at-budget' => Ncr::Reporter.proposals_pending_budget,
      'pending-at-tier-one-approval' => Ncr::Reporter.proposals_tier_one_pending,
    }
  end

  def build_attachments
    date = Time.now.utc.strftime('%Y-%m-%d')
    csv_reports.each do |name, records|
      attachments[name + '-' + date + '.csv'] = Ncr::Reporter.as_csv(records)
    end
  end
end
