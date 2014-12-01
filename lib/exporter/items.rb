module Exporter
  class Items < Exporter::Base
    def headers
      CartItem.attributes
    end

    def cart_items
      self.cart.cart_items
    end

    def rows
      self.cart_items.map(&:to_a)
    end
  end
end
