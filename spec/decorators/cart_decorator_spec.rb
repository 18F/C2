require 'spec_helper'

describe CartDecorator do
  describe '#total_price' do
    it 'returns a sum of its cart items total prices' do

    cart = Cart.new(
              name: 'My Wonderfully Awesome Communicart',
              status: 'pending',
              external_id: '10203040'
              ).decorate

    cart.cart_items << FactoryGirl.create(:cart_item, description: "Item 1", price: 1.00, quantity: 2)
    cart.cart_items << FactoryGirl.create(:cart_item, description: "Item 2", price: 2.25, quantity: 3)
    cart.cart_items << FactoryGirl.create(:cart_item, description: "Item 3", price: 3.50, quantity: 4)

    expect(cart.total_price).to eq 22.75

    end
  end
end
