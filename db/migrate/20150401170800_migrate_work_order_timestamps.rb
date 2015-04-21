class MigrateWorkOrderTimestamps < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ncr_work_orders
      SET created_at = proposals.created_at,
          updated_at = proposals.updated_at
      FROM proposals
      WHERE proposals.client_data_id = ncr_work_orders.id
        AND proposals.client_data_type = 'Ncr::WorkOrder'
        AND ncr_work_orders.created_at is NULL
        AND ncr_work_orders.updated_at is NULL;
    SQL
  end
  # no down as we don't want to lose this information
end
