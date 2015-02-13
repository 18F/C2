class Approval < ActiveRecord::Base
  include ThreeStateWorkflow

  workflow_column :status

  belongs_to :cart
  belongs_to :user
  has_one :approval_group, through: :cart
  delegate :full_name, :email_address, :to => :user, :prefix => true
  delegate :approvals, :to => :cart, :prefix => true

  acts_as_list scope: :cart

  validates :role, presence: true, inclusion: {in: UserRole::ROLES}
  # TODO validates_uniqueness_of :user_id, scope: cart_id
  validates :status, presence: true,
            inclusion: {in: workflow_spec.states.keys.map(&:to_s)}

  scope :approvable, -> { where.not(role: ['requester','observer']) }
  scope :pending, ->    { approvable.where(status: 'pending') }
  scope :received, ->   { approvable.where.not(status: 'pending') }
  scope :approved, ->   { approvable.where(status: 'approved') }


  # TODO this should be a proper association
  def user_role
    UserRole.find_by(approval_group_id: cart.approval_group.id, user_id: user_id)
  end

  def create_api_token!
    ApiToken.create!(
      cart_id: self.cart_id,
      expires_at: Time.now + 7.days,
      user_id: self.user_id
    )
  end

  def api_token
    ApiToken.fresh.where(
      cart_id: self.cart_id,
      user_id: self.user_id
    ).last
  end

  def self.new_from_user_role(user_role)
    self.new(
      position: user_role.position,
      role: user_role.role,
      user_id: user_role.user_id
    )
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
    self.cart.update_approval_status
    Dispatcher.on_approval_status_change(self)  # todo - move this out
  end

  # Used by the state machine
  def on_approved_entry(new_state, event)
    self.cart.update_approval_status
    Dispatcher.on_approval_status_change(self)  # todo - move this out
  end
end
