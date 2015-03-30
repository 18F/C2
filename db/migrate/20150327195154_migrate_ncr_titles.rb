class MigrateNcrTitles < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ncr_work_orders
      SET name = carts.name
      FROM carts, proposals
      WHERE carts.proposal_id = proposals.id
        AND proposals.client_data_id = ncr_work_orders.id
        AND proposals.client_data_type = 'Ncr::WorkOrder';
    SQL
  end
  def down
    execute <<-SQL
      UPDATE carts
      SET name = ncr_work_orders.name
      FROM ncr_work_orders, proposals
      WHERE carts.proposal_id = proposals.id
        AND proposals.client_data_id = ncr_work_orders.id
        AND proposals.client_data_type = 'Ncr::WorkOrder';
    SQL
  end
end
