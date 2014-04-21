require 'spec_helper'

describe CartDecorator do
  describe '#total_price' do
    it 'returns a sum of its cart items total prices' do

    cart = Cart.new(
              name: 'My Wonderfully Awesome Communicart',
              status: 'pending',
              external_id: '10203040'
              ).decorate

    cart.cart_items << FactoryGirl.create(:cart_item, description: "Item 1", price: 1.00)
    cart.cart_items << FactoryGirl.create(:cart_item, description: "Item 2", price: 2.25)
    cart.cart_items << FactoryGirl.create(:cart_item, description: "Item 3", price: 3.50)

    expect(cart.total_price).to eq 6.75

    end
  end
end
