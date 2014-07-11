require 'spec_helper'

describe CartItem do
  let(:cart_item) { FactoryGirl.create(:cart_item) }
  let(:trait) { FactoryGirl.create(:cart_item_trait) }
  let(:feature_trait) { FactoryGirl.create(:cart_item_trait, name: 'feature', value: 'bpa') }
  let(:socio_trait_1) { FactoryGirl.create(:cart_item_trait, name: 'socio', value: 's') }
  let(:socio_trait_2) { FactoryGirl.create(:cart_item_trait, name: 'socio', value: 'w') }

  describe '#green?' do
    it 'returns false with the absence of a green trait' do
      expect(cart_item.green?).to eq false
    end

    it 'returns true with the presence of a green trait'do
      cart_item.cart_item_traits << trait
      expect(cart_item.green?).to eq true
    end
  end

  describe '#features' do
    it 'returns an empty array of features when they are not present' do
      expect(cart_item.features).to eq []
    end

    it 'returns an array of features when they are present' do
      cart_item.cart_item_traits << feature_trait
      expect(cart_item.features).to eq ['bpa']
    end
  end

  describe '#socio' do
    it 'returns an empty array of features when they are not present' do
      expect(cart_item.socio).to eq []
    end

    it 'returns an array of features when they are present' do
      cart_item.cart_item_traits << socio_trait_1
      cart_item.cart_item_traits << socio_trait_2
      expect(cart_item.socio).to eq ['s','w']
    end
  end

  describe "#formatted_price" do
    it 'returns a formatted version of a cart item price' do
      cart_item.price = 1.8
      expect(cart_item.formatted_price).to eq "$ 1.80"
    end
  end
end
