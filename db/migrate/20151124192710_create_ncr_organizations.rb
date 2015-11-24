require_relative "../chores/ncr_organization_importer"
require_relative "../chores/ncr_work_order_organization_reassigner"

class CreateNcrOrganizations < ActiveRecord::Migration
  def up
    create_table :ncr_organizations do |t|
      t.timestamps null: false
      t.string :code, null: false
      t.string :name, null: false, default: ""
    end

    add_reference :ncr_work_orders, :ncr_organization, index: true

    Ncr::OrganizationImporter.new.run
    Ncr::WorkOrderOrganizationReassigner.new.run

    remove_column :ncr_work_orders, :org_code
  end

  def down
    add_column :ncr_work_orders, :org_code, :string

    Ncr::WorkOrderOrganizationReassigner.new.unrun

    drop_table :ncr_organizations
    remove_reference :ncr_work_orders, :ncr_organization
  end
end
