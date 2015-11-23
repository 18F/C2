class AddPurchaseTypeToGsa18fProcurements < ActiveRecord::Migration
  def change
    add_column :gsa18f_procurements, :purchase_type, :integer

    execute <<-SQL
      UPDATE gsa18f_procurements SET purchase_type = 0 WHERE purchase_type IS NULL;
      SQL

      change_column_null :gsa18f_procurements, :purchase_type, false
  end
end
