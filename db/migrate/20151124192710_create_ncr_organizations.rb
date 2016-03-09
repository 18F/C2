require_relative "../chores/ncr_organization_importer"
require_relative "../chores/ncr_work_order_organization_reassigner"

class CreateNcrOrganizations < ActiveRecord::Migration
  def up
    create_table :ncr_organizations do |t|
      t.timestamps null: false
      t.string :code, null: false
      t.string :name, null: false, default: ""
    end

    Ncr::OrganizationImporter.new.run
  end

  def down
    drop_table :ncr_organizations
  end
end
