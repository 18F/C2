class AddPegasysDocumentNumberTo18f < ActiveRecord::Migration
  def up
    add_column :gsa18f_procurements, :pegasys_document_number, :string
  end
  def down
    remove_column :gsa18f_procurements, :pegasys_document_number, :string
  end
end
