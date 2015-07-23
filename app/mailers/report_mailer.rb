class ReportMailer < ActionMailer::Base

  add_template_helper ReportHelper

  def budget_status(to_email)
    @total_last_week  = Proposal.where(client_data_type: "Ncr::WorkOrder")
                                .where("created_at > ?",1.week.ago).count
    @total_unapproved = Proposal.pending.where(client_data_type: "Ncr::WorkOrder").count

    @ba60_proposals = Proposal.where(status:'approved').where("created_at > ?",1.week.ago).where(client_data_type: "Ncr::WorkOrder").map(&:client_data).select{|d| d.expense_type == "BA60"};nil
    @ba61_proposals = Proposal.where(status:'approved').where("created_at > ?",1.week.ago).where(client_data_type: "Ncr::WorkOrder").map(&:client_data).select{|d| d.expense_type == "BA61"}
    @ba80_proposals = Proposal.where(status:'approved').where("created_at > ?",1.week.ago).where(client_data_type: "Ncr::WorkOrder").map(&:client_data).select{|d| d.expense_type == "BA80"};nil

    @proposals_pending_approving_official = Proposal.where(client_data_type: "Ncr::WorkOrder").where(status: "pending").select{|p| p.approvals.pluck(:status)[0] == 'actionable'};nil
    @proposals_pending_budget = Proposal.where(client_data_type: "Ncr::WorkOrder").where(status: "pending").select{|p| p.approvals.pluck(:status).last == 'actionable'}.sort{|a,b|a.client_data.expense_type <=> b.client_data.expense_type};nil

    # headers['In-Reply-To'] = @proposal.email_msg_id
    # headers['References'] = @proposal.email_msg_id

    mail(
      to: to_email,
      subject: "C2: Daily Budget report for #{Time.now.in_time_zone('Eastern Time (US & Canada)').strftime("%a %m/%d/%y")}",
      from: 'communicart.sender@gsa.gov',
      template_name: 'budget_report_email'
    )

  end

end