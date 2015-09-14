module Ncr
  module Reporter
    def self.total_last_week
      Proposal.where(client_data_type: "Ncr::WorkOrder")
              .where("created_at > ?",1.week.ago).count
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

    def self.proposals_pending_approving_official
      approver_sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT a.proposal_id FROM approvals AS a
        WHERE a.status='actionable'
        AND a.type='Approvals::Individual'
        ORDER BY a.position ASC
        LIMIT 1
      SQL

      sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT * FROM proposals AS p
        WHERE p.status='pending'
        AND p.client_data_type='Ncr::WorkOrder'
        AND p.id IN (#{approver_sql})
      SQL
      Proposal.find_by_sql(sql)
    end

    def self.proposals_pending_budget
      approver_sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT a.proposal_id FROM approvals AS a
        WHERE a.status='actionable'
        AND a.type='Approvals::Individual'
        ORDER BY a.position DESC
        LIMIT 1
      SQL

      sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT * FROM proposals AS p
        INNER JOIN ncr_work_orders AS nwo ON p.client_data_id=nwo.id
        WHERE p.status='pending'
        AND p.client_data_type='Ncr::WorkOrder'
        AND p.id IN (#{approver_sql})
        ORDER BY nwo.expense_type
      SQL
      Proposal.find_by_sql(sql)
    end

    def self.budget_proposals(type, timespan)
      sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT * FROM proposals AS p
        INNER JOIN ncr_work_orders AS nwo ON p.client_data_id=nwo.id
        WHERE p.status='pending'
        AND p.client_data_type='Ncr::WorkOrder'
        AND p.created_at > ?
        AND nwo.expense_type = ?
      SQL
      Proposal.find_by_sql([sql, timespan, type])
    end

    def self.proposals_tier_one_pending_sql
      tier_one_sql = User.sql_for_role_slug('BA61_tier1_budget_approver', 'ncr')

      approver_sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT a.proposal_id FROM approvals AS a
        WHERE a.status='actionable' AND a.user_id IN (#{tier_one_sql})
      SQL

      work_order_sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT id FROM ncr_work_orders AS nwo
        WHERE nwo.org_code!='#{Ncr::Organization::WHSC_CODE}'
        AND nwo.expense_type IN ('BA60','BA61')
      SQL

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
