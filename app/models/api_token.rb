class ApiToken < ActiveRecord::Base
  before_create :generate_token

  belongs_to :approval
  has_one :cart, through: :approval
  has_one :user, through: :approval

  validates_presence_of :approval_id

  scope :unexpired, -> { where('expires_at >= ?', Time.now) }
  scope :expired, -> { where('expires_at < ?', Time.now) }
  scope :unused, -> { where(used_at: nil) }
  scope :fresh, -> { unused.unexpired }

  delegate :cart_id, to: :approval

  def generate_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)

    self.expires_at ||= Time.now + 7.days
  end
end
