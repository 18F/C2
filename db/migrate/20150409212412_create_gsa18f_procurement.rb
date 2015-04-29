class CreateGsa18fProcurement < ActiveRecord::Migration
  def change
    create_table :gsa18f_procurements do |t|
    	t.string :office
    	t.text :justification
    	t.string :link_to_product
    	t.integer :quantity
    	t.datetime :date_requested
    	t.string :additional_info
    	t.decimal :cost_per_unit
    	t.text :product_name_and_description
    	t.boolean :recurring
    	t.string :recurring_interval
    	t.integer :recurring_length
    end
  end
end