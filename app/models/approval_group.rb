class ApprovalGroup < ActiveRecord::Base
  enum flow: [:parallel, :linear]

  belongs_to :cart
  has_many :user_roles
  has_many :users, through: :user_roles

  validates :name, presence: true, uniqueness: true
  validates :flow, presence: true


  def requester_id
    if ur = user_roles.find { |r| r.role == "requester"}
      return ur.user_id
    end
  end

end
