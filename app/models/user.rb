class User < ActiveRecord::Base
  validates_presence_of :email_address
  validates_uniqueness_of :email_address
  has_many :user_roles
  has_many :approval_groups, through: :user_roles
  has_many :approvals
  has_many :approver_comments

  def full_name
    "#{first_name} #{last_name}"
  end

end
