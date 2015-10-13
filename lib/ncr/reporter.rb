module Ncr
  module Reporter
    def self.total_last_week
      Proposal.where(client_data_type: "Ncr::WorkOrder")
        .where("created_at > ?", 1.week.ago).count
    end

    def self.total_unapproved
      Proposal.pending.where(client_data_type: "Ncr::WorkOrder").count
    end

    def self.ba60_proposals
      budget_proposals("BA60", 1.week.ago)
    end

    def self.ba61_proposals
      budget_proposals("BA61", 1.week.ago)
    end

    def self.ba80_proposals
      budget_proposals("BA80", 1.week.ago)
    end

    def self.proposal_public_url(proposal)
      Rails.application.routes.url_helpers.url_for(controller: 'proposals', action: 'show', id: proposal.id, host: DEFAULT_URL_HOST)
    end

    def self.build_ncr_annual_report_string(year)
      work_orders = Ncr::WorkOrder.approved.for_fiscal_year(year)
      CSV.generate do |csv|
        csv << ["Amount", "Date Approved", "Org Code", "CL#", "Budget Activity", "SOC", "Function Code", "Building #",
                "Vendor", "Description", "Requestor", "Approver"]
        self.get_ncr_annual_report_body(csv, work_orders)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def self.get_ncr_annual_report_body(csv, work_orders)
      work_orders.each do |w|
        approver_name = w.approving_official ? w.approving_official.full_name : "no approver listed"
        approved_at = w.proposal.approvals.last ? w.proposal.approvals.last.approved_at : "no approvals"
        csv << [w.amount, approved_at, w.org_code, w.cl_number, w.expense_type, w.soc_code,
                w.function_code, w.building_number, w.vendor, w.description, w.proposal.requester.full_name, approver_name]
      end
    end
    # rubocop:enable Metrics/AbcSize

    def self.make_csv_row(proposal)
      [
        self.proposal_public_url(proposal),
        proposal.requester.email_address,
        proposal.client_data.decorate.current_approver_email_address,
        proposal.client_data.cl_number,
        proposal.client_data.function_code,
        proposal.client_data.soc_code,
        proposal.created_at
      ]
    end

    def self.as_csv(proposals)
      CSV.generate do |csv|
        csv << ['URL', 'Requester', 'Approver', 'CL', 'Function Code', 'Soc Code', 'Created']
        proposals.each do |p|
          csv << self.make_csv_row(p)
        end
      end
    end

    def self.proposals_pending_approving_official
      # TODO convert to SQL
      Proposal.pending
        .where(client_data_type: 'Ncr::WorkOrder')
        .select { |p| p.individual_approvals.pluck(:status)[0] == 'actionable' }
    end

    def self.proposals_pending_budget
      # TODO convert to SQL
      Proposal.pending
        .where(client_data_type: 'Ncr::WorkOrder')
        .select { |p| p.individual_approvals.pluck(:status).last == 'actionable' }
        .sort_by { |pr| pr.client_data.expense_type }
    end

    def self.budget_proposals(type, timespan)
      # TODO convert to SQL
      Proposal.approved
        .where(client_data_type: 'Ncr::WorkOrder')
        .where('created_at > ?', timespan)
        .select { |pr| pr.client_data.expense_type == type }
    end

    def self.proposals_tier_one_pending_approver_sql
      tier_one_sql = User.sql_for_role_slug('BA61_tier1_budget_approver', 'ncr')

      <<-SQL.gsub(/^ {8}/, '')
        SELECT a.proposal_id FROM approvals AS a
        WHERE a.status='actionable' AND a.user_id IN (#{tier_one_sql})
      SQL
    end

    def self.proposals_tier_one_work_order_sql
      <<-SQL.gsub(/^ {8}/, '')
        SELECT id FROM ncr_work_orders AS nwo
        WHERE nwo.org_code!='#{Ncr::Organization::WHSC_CODE}'
        AND nwo.expense_type IN ('BA60','BA61')
      SQL
    end

    def self.proposals_tier_one_pending_sql
      approver_sql   = self.proposals_tier_one_pending_approver_sql
      work_order_sql = self.proposals_tier_one_work_order_sql
      <<-SQL.gsub(/^ {8}/, '')
        SELECT * FROM proposals AS p
        WHERE p.status='pending'
        AND p.client_data_type='Ncr::WorkOrder'
        AND p.client_data_id IN (#{work_order_sql})
        AND p.id IN (#{approver_sql})
      SQL
    end

    def self.proposals_tier_one_pending
      Proposal.find_by_sql(self.proposals_tier_one_pending_sql)
    end
  end
end
