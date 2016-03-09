class UserDelegate < ActiveRecord::Base
  has_paper_trail class_name: "C2Version"

  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id"
  belongs_to :assigner, class_name: "User", foreign_key: "assigner_id"

  validates :assigner, presence: true
  validates :assignee, presence: true
  validates :assignee_id, uniqueness: { scope: :assigner_id }
  validate :assigner_and_assignee_are_different_users

  private

  def assigner_and_assignee_are_different_users
    if assigner == assignee
      errors.add(:assignee, "cannot be same user as assigner")
    end
  end
end
