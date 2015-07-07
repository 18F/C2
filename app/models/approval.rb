class Approval < ActiveRecord::Base
  include WorkflowModel
  workflow do
    state :pending do
      event :make_actionable, transitions_to: :actionable
    end
    state :actionable do
      event :approve, transitions_to: :approved
    end
    state :approved
  end

  belongs_to :proposal
  belongs_to :user
  belongs_to :parent, class_name: 'Approval'
  has_one :cart, through: :proposal
  has_one :api_token, -> { fresh }
  has_one :approval_group, through: :cart
  has_one :user_role, -> { where(approval_group_id: cart.approval_group.id, user_id: self.user_id) }
  has_many :child_approvals, class_name: 'Approval', foreign_key: 'parent_id'

  delegate :full_name, :email_address, :to => :user, :prefix => true
  delegate :approvals, :to => :cart, :prefix => true

  acts_as_list scope: :proposal

  # TODO validates_uniqueness_of :user_id, scope: cart_id

  # @todo: remove and replace calls with "with_xxx_state"
  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end

  default_scope { order('position ASC') }

  # TODO remove
  def cart_id
    self.proposal.cart.id
  end

  # TODO we should probably store this value
  def approved_at
    if self.approved?
      self.updated_at
    else
      nil
    end
  end

  # notify parents if we've been approved. Notified as a callback so that it
  # will be present even if subclasses override workflow
  def on_approved_entry(old_state, event)
    if self.parent
      self.parent.child_approved!
    else
      self.proposal.approve!
    end
  end
end
