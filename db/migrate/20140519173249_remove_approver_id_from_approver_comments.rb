class RemoveApproverIdFromApproverComments < ActiveRecord::Migration
  def change
    remove_column :approver_comments, :approver_id, :integer
  end
end
