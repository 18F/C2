class AddNewFeaturesDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :new_features_date, :string
  end
end
