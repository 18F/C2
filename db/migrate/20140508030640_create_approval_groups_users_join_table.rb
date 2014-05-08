class CreateApprovalGroupsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :approval_groups_users, id: false do |t|
      t.references :approval_group, null: false
      t.references :users, null: false
    end
  end
end
