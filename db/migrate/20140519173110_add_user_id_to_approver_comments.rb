class AddUserIdToApproverComments < ActiveRecord::Migration
  def change
    add_column :approver_comments, :user_id, :integer
  end
end
