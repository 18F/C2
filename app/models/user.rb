class User < ActiveRecord::Base
  validates_presence_of :email_address
  validates_uniqueness_of :email_address
  has_and_belongs_to_many :approval_groups
  has_many :approvals

end
