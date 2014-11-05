require 'rails_helper'

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

    it 'getProp and setProp work on a cart_item' do
      cart_item.setProp('spud','bud')
      v = cart_item.getProp('spud')
      expect(v).to eq "bud"
    end

    it 'two properties can be added to a cart_item' do
      cart_item.setProp('spud','bud')
      cart_item.setProp('love','dove')
      expect(cart_item.getProp('spud')).to eq "bud"
      expect(cart_item.getProp('love')).to eq "dove"
    end

    it 'two properties can be added to two distinct kinds of objects' do
      cart_item.setProp('spud','bud')
      user.setProp('love','dove')

      expect(cart_item.getProp('spud')).to eq "bud"
      expect(user.getProp('love')).to eq "dove"
    end

    it 'two properties can be added under oen tag.' do
      cart_item.setProp('spud','bud')
      cart_item.setProp('love','dove')
      cart_item.setProp('spud','stud')

      expect(cart_item.getProp('spud')).to eq "stud"
      expect(cart_item.getProp('love')).to eq "dove"
    end

    it 'a HashWithIndifferentAccess can be set to a property' do
      hsh = ActiveSupport::HashWithIndifferentAccess.new(love: 'dove')
      cart_item.setProp('spud', hsh)

      expect(cart_item.getProp('spud')).to eq hsh
    end

    it 'Can create an informal cart with items that evolve over time' do

      firstComment = 'cannot find this'
      originatingEmail = 'get: description #1, #2, #3, and give to Jane, Jill and Tom'
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
      cart_item.setProp('comment0',firstComment)
      cart_item.setProp('comment1','found it on the web')
      cart_item.setProp('comment2','but is it good enough?')

      informal_cart.setProp('originatingEmail',originatingEmail)
      expect(cart_item.getProp('comment0')).to eq firstComment
      expect(informal_cart.getProp('originatingEmail')).to eq originatingEmail

    end
  end
end
