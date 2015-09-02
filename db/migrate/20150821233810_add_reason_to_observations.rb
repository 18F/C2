class AddReasonToObservations < ActiveRecord::Migration
  def change
    add_column :observations, :reason, :string
  end
end
