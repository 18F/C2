class ApprovalGroup < ActiveRecord::Base
  has_many :approvers #TODO: Remove when users are in place
  belongs_to :cart
  has_one :requester
  has_and_belongs_to_many :users
  validates_uniqueness_of :name

  accepts_nested_attributes_for :approvers #TODO: Remove when users are in place
end

