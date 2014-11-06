class Approval < ActiveRecord::Base
  STATUSES = %w(pending approved rejected)

  belongs_to :cart
  belongs_to :user

  validates_presence_of :role
  # TODO validates_uniqueness_of :user_id, scope: cart_id
  validates :status, presence: true, inclusion: {in: STATUSES}

  after_initialize :set_default_status

  def set_default_status
    self.status ||= 'pending'
  end
end
