class RenameApprovalTypesToStepTypes < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE steps SET type = 'Steps::Serial'   WHERE type = 'Approvals::Serial';
      UPDATE steps SET type = 'Steps::Parallel' WHERE type = 'Approvals::Parallel';
      UPDATE steps SET type = 'Steps::Approval' WHERE type = 'Approvals::Individual';
    SQL
  end

  def down
    execute <<-SQL
      UPDATE steps SET type = 'Approvals::Serial'     WHERE type = 'Steps::Serial';
      UPDATE steps SET type = 'Approvals::Parallel'   WHERE type = 'Steps::Parallel';
      UPDATE steps SET type = 'Approvals::Individual' WHERE type = 'Steps::Approval';
    SQL
  end
end
