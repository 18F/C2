class AddClientSlugToUsers < ActiveRecord::Migration
  def change
    add_column :users, :client_slug, :string
  end
end
