class AddPositionToUserRole < ActiveRecord::Migration
  def change
    add_column :user_roles, :position, :integer
  end
end
