class Cart < ActiveRecord::Base
  # TODO: states: awaiting_approvals, approved, rejected
  has_many :approvals

  def self.update_status_for_cart(cart_id)
    cart = Cart.find_by_id(cart_id)
    cart.update_attributes(status: 'approved') if cart.has_all_approvals?
  end

  def has_all_approvals?
    self.approvals.count > 0 && self.approvals.reject { |status| status == 'approved' }.empty?
  end

  def self.create_from_cart_items(params)
    Cart.create(name: params['description'], status: 'pending')
  end
end
