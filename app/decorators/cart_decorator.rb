class CartDecorator < Draper::Decorator
  delegate_all

  def total_price
    object.cart_items.reduce(0) do |sum,citem| sum + (citem.quantity * citem.price) end
  end

end
