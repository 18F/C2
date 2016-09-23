class ChangeEventColumnNames < ActiveRecord::Migration
  def change
    rename_column :gsa18f_events, :title_of_training, :title_of_event
    rename_column :gsa18f_events, :training_provider, :event_provider
  end
end
