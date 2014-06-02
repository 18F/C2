class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.integer :approval_group_id
      t.integer :user_id
      t.string :role
    end
  end
end
