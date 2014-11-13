class ApprovalGroup < ActiveRecord::Base
  FLOWS = %w(parallel linear).freeze

  belongs_to :cart
  has_many :user_roles
  has_many :users, through: :user_roles

  validates :flow, presence: true, inclusion: {in: FLOWS}
  validates :name, presence: true, uniqueness: true


  def users_by_role(role)
    self.users.where(user_roles: {role: role})
  end

  def approvers
    self.users_by_role('approver')
  end

  def observers
    self.user_by_role('observer')
  end

  def requester_id
    role = self.user_roles.where(role: 'requester').first
    role.try(:user_id)
  end

  def requester
    self.users_by_role('requester').first
  end
end
