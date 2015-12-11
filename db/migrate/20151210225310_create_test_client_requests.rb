class CreateTestClientRequests < ActiveRecord::Migration
  def change
    create_table :test_client_requests do |t|
      t.decimal :amount
      t.string :project_title

      t.timestamps null: false
    end
  end
end
