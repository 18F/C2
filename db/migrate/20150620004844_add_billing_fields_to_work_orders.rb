class AddBillingFieldsToWorkOrders < ActiveRecord::Migration
  def change
    change_table :ncr_work_orders do |t|
      t.string :cl_number
      t.string :function_code
      t.string :soc_code
    end
  end
end
