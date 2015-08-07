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
      # TODO convert to SQL
      Proposal.where(client_data_type: "Ncr::WorkOrder")
              .where(status: "pending")
              .select{ |p| p.approvals.pluck(:status)[0] == 'actionable' }
    end

    def self.proposals_pending_budget
      # TODO convert to SQL
      Proposal.where(client_data_type: "Ncr::WorkOrder")
              .where(status: "pending")
              .select{ |p| p.approvals.pluck(:status).last == 'actionable' }
              .sort{ |a,b|a.client_data.expense_type <=> b.client_data.expense_type }
    end

    def self.budget_proposals(type, timespan)
      # TODO convert to SQL
      Proposal.approved
              .where(client_data_type: "Ncr::WorkOrder")
              .where("created_at > ?", timespan)
              .map(&:client_data).select{|d| d.expense_type == type}
    end
  end
end
