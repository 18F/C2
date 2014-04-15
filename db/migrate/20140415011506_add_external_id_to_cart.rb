class AddExternalIdToCart < ActiveRecord::Migration
  def change
    add_column :carts, :external_id, :integer
  end
end
