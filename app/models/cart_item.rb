class CartItem < ActiveRecord::Base
  belongs_to :cart
  has_many :cart_item_traits
end
