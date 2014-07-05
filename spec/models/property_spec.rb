require 'spec_helper'

describe Property do
  let(:cart_item) { FactoryGirl.create(:cart_item) }
  let(:user) { User.create!(email_address: 'test-requester@some-dot-gov.gov') }
let(:informal_cart) { FactoryGirl.create(:cart, name: 'Informal Cart') }

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

    it 'two properties can be added to two distinct kinds of objects' do
      p0 = Property.create(property: 'spud',value: 'bud')
      p1 = Property.create(property: 'love',value: 'dove')
      p0.update_attribute(:hasproperties,cart_item)
      p1.update_attribute(:hasproperties,user)
      cartProps = Property.where(:hasproperties_id => cart_item.id,:hasproperties_type => "CartItem")
      userProps = Property.where(:hasproperties_id => user.id,:hasproperties_type => "User")
      # I don't actually believe this order is guaranteed!
      expect(cartProps[0].value).to eq "bud"
      expect(cartProps[0].property).to eq "spud"

      expect(userProps[0].value).to eq "dove"
      expect(userProps[0].property).to eq "love"
    end

    it 'two properties can be added under oen tag.' do
      p0 = Property.create(property: 'spud',value: 'bud')
      p1 = Property.create(property: 'love',value: 'dove')
      p2 = Property.create(property: 'spud',value: 'stud')
      p0.update_attribute(:hasproperties,cart_item)
      p1.update_attribute(:hasproperties,cart_item)
      p2.update_attribute(:hasproperties,cart_item)

      cartProps = Property.where(:hasproperties_id => cart_item.id,:hasproperties_type => "CartItem",:property => 'spud')
      # I don't actually believe this order is guaranteed!

      expect(cartProps[0].value).to eq "bud"
      expect(cartProps[0].property).to eq "spud"

      expect(cartProps[1].value).to eq "stud"
      expect(cartProps[1].property).to eq "spud"

    end

    it 'Can create an informal cart with items that evolve over time' do
      # first we create the Cart with a few items
      ci0 = CartItem.create(
        :description => 'description #1',
        :url => 'something for a different vendor',
        :notes => 'just a note: Bob, give this to Jane.',
        :quantity => 'about a dozen',
        :cart_id => informal_cart.id
      )
      # first we create the Cart with a few items
      ci1 = CartItem.create(
        :description => 'description #2',
        :url => 'something for a different vendor',
        :notes => 'just a note: Bob, give this to Jill.',
        :quantity => 'about two dozen',
        :cart_id => informal_cart.id
      )
      # first we create the Cart with a few items
      ci2 = CartItem.create(
        :description => 'description #3',
        :url => 'something for a different vendor',
        :notes => 'just a note: Bob, give this to Tom.',
        :quantity => 'about three dozen',
        :cart_id => informal_cart.id
      )
      # Then we use our helper functions to decorate it with values
      p0 = Property.create(property: 'comment0',value: 'cannot find this')
      p1 = Property.create(property: 'comment1',value: 'found it on the web')
      p2 = Property.create(property: 'comment2',value: 'but is it good enough?')
      p0.update_attribute(:hasproperties,ci0)
      p1.update_attribute(:hasproperties,ci0)
      p2.update_attribute(:hasproperties,ci0)
      
      # Then we use our helper functions to read out those values
      ci0Props = Property.where(:hasproperties_id => ci0.id,:hasproperties_type => "CartItem",:property => 'comment0')
      expect(ci0Props[0].value).to eq 'cannot find this'
      
    end
  end
end
