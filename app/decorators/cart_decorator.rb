class CartDecorator < Draper::Decorator
  delegate_all

  def total_price
    object.cart_items.map(&:price).inject { |sum, price| sum + price }
  end

end
