class ApiToken < ActiveRecord::Base
  before_create :generate_token

  def generate_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)

  end
end
