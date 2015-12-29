class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name, null: false
      t.text :query, null: false
      t.boolean :shared, default: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
