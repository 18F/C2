class UpdateNcrNameColumn < ActiveRecord::Migration
  def change
    rename_column :ncr_work_orders, :name, :project_title
  end
end