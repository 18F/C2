class Role < ActiveRecord::Base
  has_many :proposal_roles
  has_many :proposals, through: :proposal_roles
  has_many :user_roles
  has_many :users, through: :user_roles
end
