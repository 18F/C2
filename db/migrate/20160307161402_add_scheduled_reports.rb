class AddScheduledReports < ActiveRecord::Migration
  def change
    create_table :scheduled_reports do |t|
      t.string :name, null: false
      t.string :frequency, null: false
      t.integer :user_id, null: false
      t.integer :report_id, null: false
      t.timestamps
    end
    add_foreign_key :scheduled_reports, :users
    add_foreign_key :scheduled_reports, :reports
  end
end
