class Proposal < ActiveRecord::Base
  has_one :cart

  validates :flow, presence: true, inclusion: {in: ApprovalGroup::FLOWS}
  validates :status, presence: true, inclusion: {in: Approval::STATUSES}

  after_initialize :set_default_flow


  def set_default_flow
    self.flow ||= 'parallel'
  end
end
