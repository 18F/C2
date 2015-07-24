class AddTypeToApprovals < ActiveRecord::Migration
  def up
    add_column :approvals, :type, :string
    execute <<-SQL
      UPDATE approvals
      SET type = 'Approvals::Individual';
    SQL
  end

  def down
    remove_column :approvals, :type, :string
  end
end
