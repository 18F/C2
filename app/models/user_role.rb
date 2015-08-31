class UserRole < ActiveRecord::Base

  belongs_to :user
  has_one    :role

end
