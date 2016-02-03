require_relative "../chores/ncr_organization_importer"
require_relative "../chores/ncr_work_order_organization_reassigner"

class NcrOrganizationsStringToRelation < ActiveRecord::Migration
  def up
    add_reference :ncr_work_orders, :ncr_organization, index: true

    Ncr::WorkOrderOrganizationReassigner.new.run

    remove_column :ncr_work_orders, :org_code
  end

  def down
    add_column :ncr_work_orders, :org_code, :string

    Ncr::WorkOrderOrganizationReassigner.new.unrun

    remove_reference :ncr_work_orders, :ncr_organization
  end
end
