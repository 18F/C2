class DropApproversTable < ActiveRecord::Migration
  def change
    drop_table :approvers
  end
end
