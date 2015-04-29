class AddUrgencyToGsa18fProcurement < ActiveRecord::Migration
  def change
    add_column :gsa18f_procurements, :urgency, :string
  end
end
