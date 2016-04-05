class AddUserTimezone < ActiveRecord::Migration
  def change
    add_column :users, :timezone, :string, limit: 255, default: "UTC"
  end
end
