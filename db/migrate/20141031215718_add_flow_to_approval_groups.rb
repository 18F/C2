class AddFlowToApprovalGroups < ActiveRecord::Migration
  def change
    add_column :approval_groups, :flow, :integer, default: 0
  end
end
