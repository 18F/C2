class AddClientFieldsToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :client_fields, :json
    add_column :proposals, :subclass, :string
  end
end
