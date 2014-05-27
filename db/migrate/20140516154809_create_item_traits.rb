class CreateItemTraits < ActiveRecord::Migration
  def change
    create_table :cart_item_traits do |t|
      t.text :name
      t.text :value
      t.integer :cart_item_id

      t.timestamps
    end
  end
end
