class ApprovalGroup < ActiveRecord::Base
  has_and_belongs_to_many :carts
  validates_uniqueness_of :name
  has_many :user_roles
  has_many :users, through: :user_roles

end

