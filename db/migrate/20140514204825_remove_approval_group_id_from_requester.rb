class RemoveApprovalGroupIdFromRequester < ActiveRecord::Migration
  def change
    remove_column :requesters, :approval_group_id, :integer
  end
end
