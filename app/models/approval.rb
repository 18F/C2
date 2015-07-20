class Approval < ActiveRecord::Base
  include WorkflowModel
  workflow do   # overwritten in child classes
    state :pending
    state :actionable
    state :approved
  end

  belongs_to :proposal
  belongs_to :user
  belongs_to :parent, class_name: 'Approval'
  has_one :cart, through: :proposal
  has_one :api_token, -> { fresh }
  has_many :child_approvals, class_name: 'Approval', foreign_key: 'parent_id'

  delegate :full_name, :email_address, :to => :user, :prefix => true

  acts_as_list scope: :proposal

  # TODO validates_uniqueness_of :user_id, scope: proposal_id

  # @todo: remove and replace calls with "with_xxx_state"
  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end

  default_scope { order('position ASC') }
  scope :with_users, -> { includes :user }


  # TODO we should probably store this value
  def approved_at
    if self.approved?
      self.updated_at
    else
      nil
    end
  end

  def notify_parent_approved
    if self.parent
      self.parent.child_approved!(self)
    else
      self.proposal.approve!
    end
    self.reload   # Account for proposal changes
  end
  
  # By using a min_required, we can create a disjunction
  def min_required_met?
    min_required = self.min_required || self.child_approvals.count
    self.child_approvals.approved.count >= min_required
  end
end
