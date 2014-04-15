class AddCartIdToApprovalGroup < ActiveRecord::Migration
  def change
    add_column :approval_groups, :cart_id, :integer
  end
end
