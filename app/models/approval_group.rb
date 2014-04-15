class ApprovalGroup < ActiveRecord::Base
  has_many :approvers
  belongs_to :cart
end

