class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :approval_group

  acts_as_list scope: :approval_group

  validates_presence_of :user_id
  validates_presence_of :approval_group_id
  validates_presence_of :role #TODO: restrict to: requester, approver, observer; Limit requester to only one at this time;
end
