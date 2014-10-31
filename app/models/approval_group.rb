class ApprovalGroup < ActiveRecord::Base
  enum flow: [:parallel, :linear]

  belongs_to :cart
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :user_roles
  has_many :users, through: :user_roles

  def requester_id
    if ur = user_roles.find { |r| r.role == "requester"}
      return ur.user_id
    end
  end

end
