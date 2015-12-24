class RemoveFlowFromProposals < ActiveRecord::Migration
  def up
    remove_column :proposals, :flow
  end

  def down
    add_column :proposals, :flow, :string, default: "parallel"
  end
end
