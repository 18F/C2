class Approval < ActiveRecord::Base
  include WorkflowModel
  has_paper_trail

  workflow do   # overwritten in child classes
    state :pending
    state :actionable
    state :approved
  end

  belongs_to :proposal
  acts_as_list scope: :proposal

  scope :individual, -> { where(type: 'Approvals::Individual') }


  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end

  default_scope { order('position ASC') }

  def notify_parent_approved
    self.proposal.partial_approve!
  end
end
