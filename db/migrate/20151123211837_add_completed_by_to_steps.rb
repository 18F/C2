class AddCompletedByToSteps < ActiveRecord::Migration
  def up
    add_column :steps, :completed_by_id, :integer
    add_index :steps, :completed_by_id
    execute "ALTER TABLE steps ADD CONSTRAINT completed_by_id_fkey FOREIGN KEY (completed_by_id) REFERENCES users (id)"
  end

  def down
    execute "ALTER TABLE steps DROP CONSTRAINT completed_by_id_fkey"
    remove_index :steps, :completed_by_id
    remove_column :steps, :completed_by_id
  end
end
