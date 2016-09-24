class AddFieldsToEventsTable < ActiveRecord::Migration
  def change
    add_column :gsa18f_events, :type_of_event, :text
    add_column :gsa18f_events, :free_event, :boolean, default: false
    add_column :gsa18f_events, :travel_required, :boolean, default: false
  end
end
