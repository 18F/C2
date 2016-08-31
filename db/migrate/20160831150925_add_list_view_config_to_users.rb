class AddListViewConfigToUsers < ActiveRecord::Migration
  def change
    add_column :users, :list_view_config, :text
  end
end
