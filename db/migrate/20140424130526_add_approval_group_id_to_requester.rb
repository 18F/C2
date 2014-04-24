class AddApprovalGroupIdToRequester < ActiveRecord::Migration
  def change
    add_column :requesters, :approval_group_id, :integer
  end
end
