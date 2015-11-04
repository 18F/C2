class DropProperties < ActiveRecord::Migration
  def up
    drop_table :properties
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
