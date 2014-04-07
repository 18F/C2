class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.integer :cart_id
      t.string :email_address
      t.string :status

      t.timestamps
    end
  end
end
