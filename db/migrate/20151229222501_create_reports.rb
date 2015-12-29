class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.text :query
      t.boolean :shared
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
