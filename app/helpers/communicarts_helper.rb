module CommunicartsHelper
  def total_price_from_params(cart_items)
    sum = cart_items.reduce(0) do |sum,value|
      sum + (value["qty"].gsub(/[^\d\.]/, '').to_f *  value["price"].gsub(/[^\d\.]/, '').to_f)
    end

    return sum
  end
end
