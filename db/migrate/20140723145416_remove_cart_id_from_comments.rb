class RemoveCartIdFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :cart_id, :integer
  end
end
