class CreateRequesters < ActiveRecord::Migration
  def change
    create_table :requesters do |t|
      t.string :email_address
      t.integer :cart_id

      t.timestamps
    end
  end
end
