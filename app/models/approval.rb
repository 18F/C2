class Approval < ActiveRecord::Base
  include ThreeStateWorkflow

  workflow_column :status

  belongs_to :proposal
  has_one :cart, through: :proposal
  belongs_to :user
  has_one :api_token, -> { fresh }
  has_one :approval_group, through: :cart

  delegate :full_name, :email_address, :to => :user, :prefix => true
  delegate :approvals, :to => :cart, :prefix => true

  acts_as_list scope: :proposal

  # TODO validates_uniqueness_of :user_id, scope: cart_id

  self.statuses.each do |status|
    scope status, -> { where(status: status) }
  end
  scope :received, ->   { approvable.where.not(status: 'pending') }


  # TODO this should be a proper association
  def user_role
    UserRole.find_by(approval_group_id: cart.approval_group.id, user_id: user_id)
  end

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

  # Used by the state machine
  def on_rejected_entry(new_state, event)
    self.cart.reject!
  end

  # Used by the state machine
  def on_approved_entry(new_state, event)
    self.cart.partial_approve!
    Dispatcher.on_approval_approved(self)
  end
end
