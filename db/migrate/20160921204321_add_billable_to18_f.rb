class AddBillableTo18F < ActiveRecord::Migration
  def up
    add_column :gsa18f_procurements, :is_tock_billable, :boolean
    add_column :gsa18f_procurements, :tock_project, :string
  end
  def down
    drop_column :gsa18f_procurements, :is_tock_billable, :boolean
    drop_column :gsa18f_procurements, :tock_project, :string
  end
end
