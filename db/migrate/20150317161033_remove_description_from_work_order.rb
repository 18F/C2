class RemoveDescriptionFromWorkOrder < ActiveRecord::Migration
  def change
    remove_column :ncr_work_orders, :description, :string
  end
end
