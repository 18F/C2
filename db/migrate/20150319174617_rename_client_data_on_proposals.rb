class RenameClientDataOnProposals < ActiveRecord::Migration
  def change
    rename_column :proposals, :clientdata_id, :client_data_id
    rename_column :proposals, :clientdata_type, :client_data_type
  end
end
