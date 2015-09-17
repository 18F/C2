class AddRootApprovals < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO approvals (status, position, proposal_id, type)
      SELECT 'approved', -1, proposals.id, 'Approvals::Serial'
      FROM proposals
      WHERE proposals.client_data_type = 'Ncr::WorkOrder'
      AND proposals.status = 'approved';
    SQL
    execute <<-SQL
      INSERT INTO approvals (status, position, proposal_id, type)
      SELECT 'actionable', -1, proposals.id, 'Approvals::Serial'
      FROM proposals
      WHERE proposals.client_data_type = 'Ncr::WorkOrder'
      AND proposals.status <> 'approved';
    SQL
    execute <<-SQL
      UPDATE approvals
      SET parent_id = (
        SELECT root.id
        FROM approvals root
        WHERE root.proposal_id = approvals.proposal_id
        AND root.position = -1
      )
      WHERE id IN (
        SELECT approvals.id
        FROM approvals
        INNER JOIN proposals ON (approvals.proposal_id = proposals.id)
        WHERE proposals.client_data_type = 'Ncr::WorkOrder'
        AND approvals.position <> -1
      );
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM approvals
      WHERE id IN (
        SELECT approvals.id
        FROM approvals
        INNER JOIN proposals ON (approvals.proposal_id = proposals.id)
        WHERE proposals.client_data_type = 'Ncr::WorkOrder'
        AND approvals.type = 'Approvals::Serial'
      );
    SQL
  end
end
