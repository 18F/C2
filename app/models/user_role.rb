class UserRole < ActiveRecord::Base
  ROLES = %w(approver requester observer)

  belongs_to :user
  belongs_to :approval_group
  delegate :email_address, :to => :user, :prefix => true

  acts_as_list scope: :approval_group

  validates_presence_of :user_id
  validates_presence_of :approval_group_id
  validates :role, presence: true, inclusion: {in: ROLES}
  # TODO Limit requester to only one at this time
end
