class AddCommentableIdAndCommentableTypeToComments < ActiveRecord::Migration
  def change
    add_column :comments, :commentable_id, :integer
    add_column :comments, :commentable_type, :string

    has_many :approver_comments
    has_many :users, through: :approver_comments
  end
end
