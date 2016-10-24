class AddClientSlugToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :client_slug, :string
  end
end
