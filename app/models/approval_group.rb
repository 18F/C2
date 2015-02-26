class ApprovalGroup < ActiveRecord::Base
  FLOWS = %w(parallel linear).freeze

  belongs_to :cart
  has_many :user_roles
  has_many :users, through: :user_roles

  validates :flow, presence: true, inclusion: {in: FLOWS}
  validates :name, presence: true, uniqueness: true


  def approvers
    self.users.merge(UserRole.approvers)
  end

  def observers
    self.users.merge(UserRole.observers)
  end

  def requester_id
    role = self.user_roles.requesters.first
    role.try(:user_id)
  end

  def requester
    self.users.merge(UserRole.requesters).first
  end
end
