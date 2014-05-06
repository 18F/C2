class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.integer :cart_id
      t.integer :user_id
      t.string :status

      t.timestamps
    end
  end
end
