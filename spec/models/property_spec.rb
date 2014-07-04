require 'spec_helper'

describe Property do
  let(:cart_item) { FactoryGirl.create(:cart_item) }

  describe '#properties' do
    it 'One property can be added to a cart_item' do
      p = Property.create(property: 'spud',value: 'bud')
      p.update_attribute(:hasproperties,cart_item)
      expect(cart_item.properties[0].value = "bud")
    end
    it 'two properties can be added to a cart_item' do
      p0 = Property.create(property: 'spud',value: 'bud')
      p1 = Property.create(property: 'love',value: 'dove')
      p0.update_attribute(:hasproperties,cart_item)
      p1.update_attribute(:hasproperties,cart_item)
      cartProps = Property.where(:hasproperties_id => cart_item.id,:hasproperties_type => "CartItem")
      # I don't actually believe this order is guaranteed!
      expect(cartProps[0].value).to eq "bud"
      expect(cartProps[0].property).to eq "spud"
      expect(cartProps[1].value).to eq "dove"
      expect(cartProps[1].property).to eq "love"
    end
  end

end
