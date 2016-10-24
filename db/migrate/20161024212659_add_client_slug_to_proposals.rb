class AddClientSlugToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :creators_client_slug, :string
  end
end
