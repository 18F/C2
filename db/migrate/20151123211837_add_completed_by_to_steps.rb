class AddCompletedByToSteps < ActiveRecord::Migration
  def up
    add_column :steps, :completed_by, :integer
    add_index :steps, :completed_by
    execute "ALTER TABLE steps ADD CONSTRAINT completed_by_fkey FOREIGN KEY (completed_by) REFERENCES users (id)"
  end

  def down
    execute "ALTER TABLE steps DROP CONSTRAINT completed_by_fkey"
    remove_index :steps, :completed_by
    remove_column :steps, :completed_by
  end
end
