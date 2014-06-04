class DropRequestersTable < ActiveRecord::Migration
  def change
    drop_table :requesters
  end
end
