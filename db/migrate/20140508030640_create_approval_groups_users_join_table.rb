class CreateApprovalGroupsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :approval_groups_users, id: false do |t|
      t.belongs_to :approval_group
      t.belongs_to :user
    end
  end
end
