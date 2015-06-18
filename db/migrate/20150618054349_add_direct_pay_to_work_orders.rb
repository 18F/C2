class AddDirectPayToWorkOrders < ActiveRecord::Migration
  def change
    add_column :ncr_work_orders, :direct_pay, :boolean
  end
end
