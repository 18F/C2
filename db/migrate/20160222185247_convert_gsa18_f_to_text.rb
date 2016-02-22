class ConvertGsa18FToText < ActiveRecord::Migration
  def change
    change_column :gsa18f_procurements, :office, :text
    change_column :gsa18f_procurements, :link_to_product, :text
    change_column :gsa18f_procurements, :additional_info, :text
  end
end
