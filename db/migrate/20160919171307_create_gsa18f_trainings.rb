class CreateGsa18fTrainings < ActiveRecord::Migration
  def change
    create_table :gsa18f_trainings do |t|
      t.string :duty_station
      t.integer :supervisor_id
      t.string :title_of_training
      t.string :training_provider
      t.string :purpose
      t.string :justification
      t.string :link
      t.string :instructions
      t.string :NFS_form
      t.decimal :cost_per_unit
      t.decimal :estimated_travel_expenses
      t.date :start_date
      t.date :end_date
    end
  end
end
