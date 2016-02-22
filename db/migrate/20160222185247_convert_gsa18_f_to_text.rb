class ConvertGsa18FToText < ActiveRecord::Migration
  def up
    change_column :gsa18f_procurements, :office, :text
    change_column :gsa18f_procurements, :link_to_product, :text
    change_column :gsa18f_procurements, :additional_info, :text
  end

  def down
    change_column :gsa18f_procurements, :office, :string
    change_column :gsa18f_procurements, :link_to_product, :string
    change_column :gsa18f_procurements, :additional_info, :string
  end
end
