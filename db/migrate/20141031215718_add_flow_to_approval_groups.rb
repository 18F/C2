class AddFlowToApprovalGroups < ActiveRecord::Migration
  class ApprovalGroup < ActiveRecord::Base
  end

  def change
    add_column :approval_groups, :flow, :string

    reversible do |dir|
      dir.up do
        ApprovalGroup.update_all(flow: 'parallel')
      end
    end
  end
end
