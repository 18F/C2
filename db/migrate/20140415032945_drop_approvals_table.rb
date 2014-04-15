class DropApprovalsTable < ActiveRecord::Migration
  def change
    drop_table :approvals
  end
end
