class CartItem < ActiveRecord::Base
  belongs_to :cart
  has_many :cart_item_traits

  def green?
    cart_item_traits.each do |trait|
      if trait.name == "green"
        return true
      end
    end
    return false
  end

  def trait_as_array(key)
    trts = []
    cart_item_traits.each do |trait|
      if trait.name == key
        trts << trait.value
      end
    end
    return trts
  end

  def features
    return trait_as_array("feature")
  end

  def socio
    return trait_as_array("socio")
  end
end

