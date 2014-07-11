class ApiToken < ActiveRecord::Base
  before_create :generate_token
  validates_presence_of :user_id, :cart_id
  belongs_to :cart

  def generate_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
