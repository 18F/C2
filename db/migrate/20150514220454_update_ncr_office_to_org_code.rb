class UpdateNcrOfficeToOrgCode < ActiveRecord::Migration
  def change
    rename_column :ncr_work_orders, :office, :org_code
  end
end
