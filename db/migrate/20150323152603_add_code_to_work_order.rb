class AddCodeToWorkOrder < ActiveRecord::Migration
  def change
    add_column :ncr_work_orders, :code, :string
  end
end
