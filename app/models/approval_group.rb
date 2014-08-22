class ApprovalGroup < ActiveRecord::Base
  has_and_belongs_to_many :carts
  validates_uniqueness_of :name
  has_many :user_roles
  has_many :users, through: :user_roles

  def requester_id
    ur =  user_roles.find { |r| r.role == "requester"}
    return ur.user_id
  end

end

# comment
