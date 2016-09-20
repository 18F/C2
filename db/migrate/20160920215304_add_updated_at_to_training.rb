class AddUpdatedAtToTraining < ActiveRecord::Migration
  def change
    add_column :gsa18f_trainings, :updated_at, :datetime
    add_column :gsa18f_trainings, :created_at, :datetime
  end
end
