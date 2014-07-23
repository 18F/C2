class AddCommentIdToApproverComments < ActiveRecord::Migration
  def change
    add_column :approver_comments, :comment_id, :integer
  end
end
