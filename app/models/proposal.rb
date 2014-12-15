class Proposal < ActiveRecord::Base
  has_one :cart

  validates :flow, presence: true, inclusion: {in: ApprovalGroup::FLOWS}
  validates :status, presence: true, inclusion: {in: Approval::STATUSES}
end
