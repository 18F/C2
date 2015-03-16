class CreateNcrWorkOrders < ActiveRecord::Migration
  def change
    create_table :ncr_work_orders do |t|
      t.decimal :amount
      t.text :description
      t.string :expense_type
      t.string :vendor
      t.boolean :not_to_exceed
      t.string :building_number
      t.boolean :emergency
      t.string :rwa_number
      t.string :office
    end
  end
end
