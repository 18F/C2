class Approver  < ActiveRecord::Base
  belongs_to :approval_group
  validates_presence_of :email_address
  validates_uniqueness_of :email_address, scope: :approval_group_id

end
