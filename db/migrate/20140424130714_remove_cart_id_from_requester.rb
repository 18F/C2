class RemoveCartIdFromRequester < ActiveRecord::Migration
  def change
    remove_column :requesters, :cart_id, :integer
  end
end
