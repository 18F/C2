class AddCompletedByToSteps < ActiveRecord::Migration
  def up
    add_column :steps, :completer_id, :integer
    add_index :steps, :completer_id
    execute "ALTER TABLE steps ADD CONSTRAINT completer_id_fkey FOREIGN KEY (completer_id) REFERENCES users (id)"
  end

  def down
    execute "ALTER TABLE steps DROP CONSTRAINT completer_id_fkey"
    remove_index :steps, :completer_id
    remove_column :steps, :completer_id
  end
end
