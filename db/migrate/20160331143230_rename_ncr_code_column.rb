class RenameNcrCodeColumn < ActiveRecord::Migration
  def change
    change_table :ncr_work_orders do |tbl|
      tbl.rename :code, :work_order_code
    end
  end
end
