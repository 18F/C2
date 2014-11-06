class ApprovalGroup < ActiveRecord::Base
  FLOWS = %w(parallel linear).freeze

  belongs_to :cart
  has_many :user_roles
  has_many :users, through: :user_roles

  validates :flow, presence: true, inclusion: {in: FLOWS}
  validates :name, presence: true, uniqueness: true


  def requester_id
    if ur = user_roles.find { |r| r.role == "requester"}
      return ur.user_id
    end
  end
end
