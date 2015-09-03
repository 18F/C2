class RemoveApprovalGroups < ActiveRecord::Migration
  def change
    drop_table :approval_roles
    drop_table :approval_groups
    drop_table :approval_groups_users
  end
end
