class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true

  has_many :approver_comments
  has_many :users, through: :approver_comments
end
