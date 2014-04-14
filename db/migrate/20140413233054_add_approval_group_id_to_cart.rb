class AddApprovalGroupIdToCart < ActiveRecord::Migration
  def change
    add_column :carts, :approval_group_id, :integer
  end
end
