class CartItem < ActiveRecord::Base
  include PropMixin
  belongs_to :cart
  has_many :cart_item_traits
  has_many :comments, as: :commentable
  has_many :properties, as: :hasproperties

  def green?
    cart_item_traits.map(&:name).include?('green')
  end

  def features
    cart_item_traits.select{ |trait| trait.name.include?("feature") }.map(&:value)
  end

  def socio
    cart_item_traits.select{ |trait| trait.name.include?("socio") }.map(&:value)
  end

  def formatted_price
    "$ #{'%.2f' % price}"
  end

end

