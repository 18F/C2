class UpdateApprovalsToIndividual < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE approvals
      SET type = 'Approvals::Individual'
      WHERE type is null;
    SQL
  end

  def down
    execute <<-SQL
      UPDATE approvals
      SET type = null
      WHERE type = 'Approvals::Individual';
    SQL
  end
end
