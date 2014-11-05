class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.string :access_id
      t.string :secret_key

      t.timestamps
    end
  end
end
