class AddRootApprovals < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO approvals (status, position, proposal_id, type)
      SELECT 'actionable', -1, proposals.id, 'Approvals::Parallel'
      FROM proposals WHERE proposals.flow = 'parallel';
    SQL
    execute <<-SQL
      INSERT INTO approvals (status, position, proposal_id, type)
      SELECT 'actionable', -1, proposals.id, 'Approvals::Serial'
      FROM proposals WHERE proposals.flow = 'linear';
    SQL
    execute <<-SQL
      UPDATE approvals
      SET parent_id = (SELECT root.id
                       FROM approvals root
                       WHERE root.proposal_id = approvals.proposal_id
                       AND root.type <> 'Approvals::Individual')
      WHERE type = 'Approvals::Individual';
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM approvals WHERE type <> 'Approvals::Individual';
    SQL
  end
end
