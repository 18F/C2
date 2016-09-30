class AddClientBilledToGsa18f < ActiveRecord::Migration
  def up
    add_column :gsa18f_procurements, :client_billed, :boolean
  end
  def down
    remove_column :gsa18f_procurements, :client_billed, :boolean
  end
end
