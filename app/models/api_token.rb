class ApiToken < ActiveRecord::Base
  has_paper_trail class_name: 'C2Version'

  before_create :set_expires_at
  has_secure_token :access_token

  belongs_to :step, class_name: 'Steps::Individual'
  has_one :proposal, through: :step
  has_one :user, through: :step

  validates :access_token, presence: true, on: :save
  validates :access_token, uniqueness: true
  validates :step, presence: true
  validates :expires_at, presence: true, on: :save

  scope :unexpired, -> { where('expires_at >= ?', Time.zone.now) }
  scope :expired, -> { where('expires_at < ?', Time.zone.now) }
  scope :unused, -> { where(used_at: nil) }
  scope :fresh, -> { unused.unexpired }


  def used?
    used_at.present?
  end

  def expired?
    expires_at && expires_at < Time.zone.now
  end

  def use!
    update!(used_at: Time.zone.now)
  end

  def expire!
    update(expires_at: Time.zone.now)
  end

  private

  def set_expires_at
    if expires_at.nil?
      self.expires_at = Time.zone.now + 7.days
    end
  end
end
