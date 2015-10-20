class ApiToken < ActiveRecord::Base
  has_paper_trail class_name: 'C2Version'

  before_create :generate_token

  belongs_to :step, class_name: 'Approvals::Individual'
  has_one :proposal, through: :step
  has_one :user, through: :step

  # TODO validates :access_token, presence: true
  validates :step_id, presence: true

  scope :unexpired, -> { where('expires_at >= ?', Time.zone.now) }
  scope :expired, -> { where('expires_at < ?', Time.zone.now) }
  scope :unused, -> { where(used_at: nil) }
  scope :fresh, -> { unused.unexpired }


  def used?
    !!self.used_at
  end

  # @todo: validate presence of expires_at
  def expired?
    self.expires_at && self.expires_at < Time.zone.now
  end

  def use!
    self.update_attributes!(used_at: Time.zone.now)
  end


  private

  def generate_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)

    self.expires_at ||= Time.zone.now + 7.days
  end
end
