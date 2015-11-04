class AddDefaultsToNcrWorkOrders < ActiveRecord::Migration
  def up
    change_column :ncr_work_orders, :direct_pay, :boolean, null: false, default: false
    change_column :ncr_work_orders, :emergency, :boolean, null: false, default: false
    change_column :ncr_work_orders, :not_to_exceed, :boolean, null: false, default: false
  end

  def down
    change_column :ncr_work_orders, :direct_pay, :boolean, null: true, default: nil
    change_column :ncr_work_orders, :emergency, :boolean, null: true, default: nil
    change_column :ncr_work_orders, :not_to_exceed, :boolean, null: true, default: nil
  end
end
