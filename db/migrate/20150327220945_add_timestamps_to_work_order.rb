class AddTimestampsToWorkOrder < ActiveRecord::Migration
  def change
    add_timestamps :ncr_work_orders
  end
end
