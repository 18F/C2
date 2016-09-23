class ChangeTrainingsTableToEvents < ActiveRecord::Migration
  def change
    rename_table :gsa18f_trainings, :gsa18f_events
  end
end
