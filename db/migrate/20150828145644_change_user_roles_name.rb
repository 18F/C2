class ChangeUserRolesName < ActiveRecord::Migration
  def change
    rename_table :user_roles, :approval_roles
  end
end
