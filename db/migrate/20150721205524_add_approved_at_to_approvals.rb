class AddApprovedAtToApprovals < ActiveRecord::Migration
  def up
    add_column :approvals, :approved_at, :datetime
    execute <<-SQL
      UPDATE approvals SET approved_at = updated_at
      WHERE status = 'approved';
    SQL
  end

  def down
    remove_column :approvals, :approved_at
  end
end
