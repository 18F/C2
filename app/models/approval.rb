class Approval < ActiveRecord::Base
  STATUSES = %w(pending approved rejected)

  belongs_to :cart
  belongs_to :user
  has_one :approval_group, through: :cart
  delegate :full_name, :email_address, :to => :user, :prefix => true

  acts_as_list scope: :cart

  validates :role, presence: true, inclusion: {in: UserRole::ROLES}
  # TODO validates_uniqueness_of :user_id, scope: cart_id
  validates :status, presence: true, inclusion: {in: STATUSES}

  after_initialize :set_default_status

  scope :pending, -> { where(status: 'pending') }
  scope :received, -> { where('status != ?', 'pending') }


  # TODO this should be a proper association
  def user_role
    UserRole.find_by(approval_group_id: cart.approval_group.id, user_id: user_id)
  end

  def self.new_from_user_role(user_role)
    self.new(
      position: user_role.position,
      role: user_role.role,
      user_id: user_role.user_id
    )
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end
end
