class Approval < ActiveRecord::Base
  attr_accessor :status, :email
  has_one :cart

  def update_statuses(params)
    self.update_attribute(:status, params[:approval_action])
    Cart.update_status_for_cart(params[:cart_id])
  end
end
