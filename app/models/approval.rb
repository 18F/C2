class Approval < ActiveRecord::Base
  belongs_to :cart
  belongs_to :user
  #CURRENT TODO: validates_uniqueness_of :user_id, scope: cart_id

  before_save :set_default_status

  def set_default_status
    self.status = 'pending' if self.status.nil?
  end

end
