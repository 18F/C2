class AddTimeStampsToGsa18fProcurements < ActiveRecord::Migration
  def change
  	change_table :gsa18f_procurements do |t|
  		t.timestamps
  	end
  end
end
