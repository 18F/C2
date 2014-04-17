class ApprovalGroup < ActiveRecord::Base
  has_many :approvers
  belongs_to :cart
  validates_uniqueness_of :name

  accepts_nested_attributes_for :approvers
end

