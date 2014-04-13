class ApprovalGroup < ActiveRecord::Base
  has_many :approvers
end

