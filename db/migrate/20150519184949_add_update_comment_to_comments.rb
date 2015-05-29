class AddUpdateCommentToComments < ActiveRecord::Migration
  def change
    add_column :comments, :update_comment, :boolean
  end
end
