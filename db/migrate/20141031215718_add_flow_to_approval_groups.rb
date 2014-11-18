class AddFlowToApprovalGroups < ActiveRecord::Migration
  def change
    add_column :approval_groups, :flow, :string

    reversible do |dir|
      dir.up do
        ApprovalGroup.update_all(flow: 'parallel')
      end
    end
  end
end
