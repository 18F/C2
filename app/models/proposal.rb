class Proposal < ActiveRecord::Base
  has_one :cart

  validates :flow, presence: true, inclusion: {in: ApprovalGroup::FLOWS}
  validates :status, presence: true, inclusion: {in: Approval::STATUSES}

  after_initialize :set_defaults


  def set_defaults
    self.flow ||= 'parallel'
    self.status ||= 'pending'
  end
end
