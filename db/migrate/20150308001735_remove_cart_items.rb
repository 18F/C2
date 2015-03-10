class RemoveCartItems < ActiveRecord::Migration
  def change
    drop_table :cart_items
    drop_table :cart_item_traits

    reversible do |dir|
      dir.up do
        execute <<-SQL
          DELETE FROM properties WHERE hasproperties_type = 'CartItem'
        SQL
      end
    end
  end
end
