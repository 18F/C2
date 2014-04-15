class ApprovalGroup < ActiveRecord::Base
  has_many :approvers
  belongs_to :cart
  validates_uniqueness_of :name
end

