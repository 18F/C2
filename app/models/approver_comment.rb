class ApproverComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  validates :user, :comment, presence: true
end
