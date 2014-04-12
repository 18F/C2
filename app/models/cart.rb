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

  def total_price
    return 500
  end

  def self.initialize_cart_with_items(params)
    name = !params['cartName'].blank? ? params['cartName'] : params['cartNumber']
    Cart.create(name: params['cartName'], status: 'pending')

    #TODO: accepts_nested_attributes_for
    params['cartItems'].each do |cart_item_params|
      CartItem.create(
        :vendor => cart_item_params['vendor'],
        :description => cart_item_params['description'],
        :url => cart_item_params['url'],
        :notes => cart_item_params['notes'],
        :quantity => cart_item_params['qty'],
        :details => cart_item_params['details'],
        :part_number => cart_item_params['partNumber'],
        :price => cart_item_params['price'],
        :cart_id => cart_item_params['features']
      )
    end

  end
end
