class ReportMailer < ActionMailer::Base

  add_template_helper ReportHelper

  def budget_status
    to_email = ENV.fetch('BUDGET_REPORT_RECIPIENT')

    # TODO move all of this logic to a class

    @total_last_week  = Proposal.where(client_data_type: "Ncr::WorkOrder")
                                .where("created_at > ?",1.week.ago).count
    @total_unapproved = Proposal.pending.where(client_data_type: "Ncr::WorkOrder").count

    @ba60_proposals = budget_proposals("BA60", 1.week.ago)
    @ba61_proposals = budget_proposals("BA61", 1.week.ago)
    @ba80_proposals = budget_proposals("BA80", 1.week.ago)

    @proposals_pending_approving_official = Proposal.where(client_data_type: "Ncr::WorkOrder")
                                                    .where(status: "pending")
                                                    .select{ |p| p.approvals.pluck(:status)[0] == 'actionable' }

    @proposals_pending_budget = Proposal.where(client_data_type: "Ncr::WorkOrder")
                                        .where(status: "pending")
                                        .select{ |p| p.approvals.pluck(:status).last == 'actionable' }
                                        .sort{ |a,b|a.client_data.expense_type <=> b.client_data.expense_type }

    mail(
      to: to_email,
      subject: "C2: Daily Budget report for #{Time.now.in_time_zone('Eastern Time (US & Canada)').strftime("%a %m/%d/%y")}",
      from: 'communicart.sender@gsa.gov',
      template_name: 'budget_report_email'
    )
  end

private

  def budget_proposals(type, timespan)
    Proposal.approved.where(client_data_type: "Ncr::WorkOrder")
                     .where("created_at > ?", timespan)
                     .map(&:client_data).select{|d| d.expense_type == type}
  end

end
