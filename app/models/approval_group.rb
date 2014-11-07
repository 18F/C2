class ApprovalGroup < ActiveRecord::Base
  belongs_to :cart
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :user_roles
  has_many :users, through: :user_roles

  def requester_id
    role = self.user_roles.where(role: 'requester').first
    role.try(:user_id)
  end
end
