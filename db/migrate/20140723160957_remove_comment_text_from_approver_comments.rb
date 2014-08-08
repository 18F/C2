class RemoveCommentTextFromApproverComments < ActiveRecord::Migration
  def change
    remove_column :approver_comments, :comment_text, :text
  end
end
