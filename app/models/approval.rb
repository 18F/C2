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

  belongs_to :parent, class_name: 'Approval'
  has_many :child_approvals, class_name: 'Approval', foreign_key: 'parent_id'

  scope :individual, -> { where(type: 'Approvals::Individual') }


  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end

  default_scope { order('position ASC') }

  def notify_parent_approved
    if self.parent
      self.parent.child_approved!(self)
    else
      self.proposal.approve!
    end
  end

  def children_approved?
    self.child_approvals.where.not(status: "approved").empty?
  end
end
