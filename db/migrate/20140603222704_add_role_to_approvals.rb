class AddRoleToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :role, :string
  end
end
