class AddNameAndDescriptionToWorkOrder < ActiveRecord::Migration
  def change
    add_column :ncr_work_orders, :name, :string
    add_column :ncr_work_orders, :description, :text
  end
end
