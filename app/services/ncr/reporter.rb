module Ncr
  class Reporter
    def self.proposal_public_url(proposal)
      Rails.application.routes.url_helpers.url_for(controller: 'proposals', action: 'show', id: proposal.id, host: DEFAULT_URL_HOST)
    end

    def self.make_csv_row(proposal)
      [
        proposal_public_url(proposal),
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
          csv << make_csv_row(p)
        end
      end
    end

    def self.proposals_pending_approving_official
      Proposal.pending
        .where(client_data_type: "Ncr::WorkOrder")
        .select { |p| p.individual_steps.pluck(:status)[0] == "actionable" }
    end

    def self.proposals_pending_budget
      Proposal.pending
        .where(client_data_type: 'Ncr::WorkOrder')
        .select { |p| p.individual_steps.pluck(:status).last == 'actionable' }
        .sort_by { |pr| pr.client_data.expense_type }
    end

    def self.proposals_tier_one_pending
      Proposal.find_by_sql(proposals_tier_one_pending_sql)
    end

    def self.proposals_tier_one_pending_sql
      approver_sql = proposals_tier_one_pending_approver_sql
      work_order_sql = proposals_tier_one_work_order_sql

      <<-SQL.gsub(/^ {8}/, '')
        SELECT * FROM proposals
        WHERE proposals.status='pending'
        AND proposals.client_data_type='Ncr::WorkOrder'
        AND proposals.client_data_id IN (#{work_order_sql})
        AND proposals.id IN (#{approver_sql})
      SQL
    end

    def self.proposals_tier_one_pending_approver_sql
      tier_one_sql = User.sql_for_role_slug('BA61_tier1_budget_approver', 'ncr')

      <<-SQL.gsub(/^ {8}/, '')
        SELECT a.proposal_id FROM steps AS a
        WHERE a.status='actionable' AND a.user_id IN (#{tier_one_sql})
      SQL
    end

    def self.proposals_tier_one_work_order_sql
      <<-SQL.gsub(/^ {8}/, '')
        #{work_orders_for_non_whsc_orgs} UNION #{work_orders_without_orgs}
      SQL
    end

    def self.work_orders_for_non_whsc_orgs
      <<-SQL.gsub(/^ {8}/, '')
        SELECT ncr_work_orders.id
        FROM ncr_work_orders
        JOIN ncr_organizations
        ON ncr_work_orders.ncr_organization_id = ncr_organizations.id
        WHERE ncr_organizations.code != '#{Ncr::Organization::WHSC_CODE}'
        AND ncr_work_orders.expense_type IN ('BA60','BA61')
      SQL
    end

    def self.work_orders_without_orgs
      <<-SQL.gsub(/^ {8}/, '')
        SELECT ncr_work_orders.id
        FROM ncr_work_orders
        WHERE ncr_work_orders.ncr_organization_id IS NULL
        AND ncr_work_orders.expense_type IN ('BA60','BA61')
      SQL
    end

    def build_fiscal_year_report_string(year)
      approved_work_orders = Ncr::WorkOrder.approved.for_fiscal_year(year)

      CSV.generate do |csv|
        add_fiscal_year_report_headers(csv)
        add_fiscal_year_report_body(csv, approved_work_orders)
      end
    end

    private

    def add_fiscal_year_report_headers(csv)
        csv << [
          "Id",
          "Amount",
          "Date Approved",
          "Org Code",
          "CL#",
          "Budget Activity",
          "SOC",
          "Function Code",
          "Building #",
          "Vendor",
          "Description",
          "Requestor",
          "Approver"
        ]
    end

    def add_fiscal_year_report_body(csv, work_orders)
      work_orders.each do |work_order|
        csv << [
          work_order.proposal.public_id,
          work_order.amount,
          find_approved_at(work_order),
          work_order.organization_code_and_name,
          work_order.cl_number,
          work_order.expense_type,
          work_order.soc_code,
          work_order.function_code,
          work_order.building_number,
          work_order.vendor,
          work_order.description,
          work_order.proposal.requester.full_name,
          find_approved_at(work_order)
        ]
      end
    end

    def find_approver_name(work_order)
      if work_order.approving_official.present?
        work_order.approving_official.full_name
      else
        "no approver listed"
      end
    end

    def find_approved_at(work_order)
      if work_order.proposal.steps.last.present?
        work_order.proposal.steps.last.approved_at
      else
        "no approvals"
      end
    end
  end
end
