class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.string :vendor
      t.text :description
      t.string :url
      t.text :notes
      t.integer :quantity
      t.text :details
      t.string :part_number
      t.float :price
      t.integer :cart_id

      t.timestamps
    end
  end
end
