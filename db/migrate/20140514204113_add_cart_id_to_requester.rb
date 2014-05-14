class AddCartIdToRequester < ActiveRecord::Migration
  def change
    add_column :requesters, :cart_id, :integer
  end
end
