class AddDefaultsToGsa18fProcurements < ActiveRecord::Migration
  def up
    change_column_default :gsa18f_procurements, :justification, ""
    change_column_default :gsa18f_procurements, :link_to_product, ""
    change_column_default :gsa18f_procurements, :recurring, false
    change_column_default :gsa18f_procurements, :recurring_interval, "Daily"

    execute <<-SQL
      UPDATE gsa18f_procurements SET justification = '' WHERE justification IS NULL;
      UPDATE gsa18f_procurements SET link_to_product = '' WHERE link_to_product IS NULL;
      UPDATE gsa18f_procurements SET recurring = false WHERE recurring IS NULL;
      UPDATE gsa18f_procurements SET recurring_interval = 'Daily' WHERE recurring_interval IS NULL;
    SQL

    change_column_null :gsa18f_procurements, :justification, false
    change_column_null :gsa18f_procurements, :link_to_product, false
    change_column_null :gsa18f_procurements, :recurring, false
    change_column_null :gsa18f_procurements, :recurring_interval, null: false
  end

 def down
    change_column_null :gsa18f_procurements, :justification, true
    change_column_null :gsa18f_procurements, :link_to_product, true
    change_column_null :gsa18f_procurements, :recurring, true
    change_column_null :gsa18f_procurements, :recurring_interval, true

    change_column_default :gsa18f_procurements, :justification, nil
    change_column_default :gsa18f_procurements, :link_to_product, nil
    change_column_default :gsa18f_procurements, :recurring, nil
    change_column_default :gsa18f_procurements, :recurring_interval, nil
 end
end
