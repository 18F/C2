class ApprovalGroup < ActiveRecord::Base
  FLOWS = %w(parallel linear).freeze

  belongs_to :cart
  has_many :user_roles
  has_many :users, through: :user_roles

  validates :flow, presence: true, inclusion: {in: FLOWS}
  validates :name, presence: true, uniqueness: true


  def approvers
    # position only important for linear approvals
    self.users.where(user_roles: {role: 'approver'}).order('user_roles.position ASC')
  end

  def requester_id
    role = self.user_roles.where(role: 'requester').first
    role.try(:user_id)
  end
end
