class RemoveApprovalGroupIdFromCart < ActiveRecord::Migration
  def change
    remove_column :carts, :approval_group_id, :integer
  end
end
