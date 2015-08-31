class Role < ActiveRecord::Base

  has_many :proposals, class_name: ProposalRole
  has_many :users, class_name: UserRole

end
