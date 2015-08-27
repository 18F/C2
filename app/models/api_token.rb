class ApiToken < ActiveRecord::Base
  has_paper_trail class_name: 'C2Version'

  before_create :generate_token

  belongs_to :approval, class_name: 'Approvals::Individual'
  has_one :proposal, through: :approval
  has_one :user, through: :approval

  # TODO validates :access_token, presence: true
  validates :approval_id, presence: true

  scope :unexpired, -> { where('expires_at >= ?', Time.now) }
  scope :expired, -> { where('expires_at < ?', Time.now) }
  scope :unused, -> { where(used_at: nil) }
  scope :fresh, -> { unused.unexpired }


  def used?
    !!self.used_at
  end

  # @todo: validate presence of expires_at
  def expired?
    self.expires_at && self.expires_at < Time.now
  end

  def use!
    self.update_attributes!(used_at: Time.now)
  end


  private

  def generate_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)

    self.expires_at ||= Time.now + 7.days
  end
end
