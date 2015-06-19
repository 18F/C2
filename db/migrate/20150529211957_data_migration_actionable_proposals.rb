class DataMigrationActionableProposals < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE approvals
          SET status = 'actionable'
          WHERE id in (
            -- cheating here: we should be _sorting_, but that'd be a much more
            -- complicated query and return the same results
            SELECT min(approvals.id)
            FROM proposals
            INNER JOIN approvals ON (proposal_id = proposals.id)
            WHERE proposals.flow = 'linear'
            AND approvals.status = 'pending'
            GROUP BY proposal_id
          )
        SQL
        execute <<-SQL
          UPDATE approvals
          SET status = 'actionable'
          WHERE id in (
            SELECT approvals.id
            FROM proposals
            INNER JOIN approvals ON (proposal_id = proposals.id)
            WHERE proposals.flow <> 'linear'
            AND approvals.status = 'pending'
          )
        SQL
      end

      dir.down do
        execute <<-SQL
          UPDATE approvals
          SET status = 'pending'
          WHERE status = 'actionable';
        SQL
      end
    end
  end
end
