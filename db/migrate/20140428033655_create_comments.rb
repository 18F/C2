class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :comment_text
      t.integer :cart_id

      t.timestamps
    end
  end
end
