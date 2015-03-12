describe Property do
  let(:user) { User.create!(email_address: 'test-requester@some-dot-gov.gov') }
  let(:cart) { FactoryGirl.create(:cart, name: 'Informal Cart') }

  describe '#properties' do
    it 'One property can be added to a cart' do
      p = Property.create(property: 'spud',value: 'bud')
      p.update_attribute(:hasproperties, cart)
      expect(cart.properties[0].value = "bud")
    end

    it 'getProp and setProp work on a cart' do
      cart.setProp('spud','bud')
      v = cart.getProp('spud')
      expect(v).to eq "bud"
    end

    it 'two properties can be added to a cart' do
      cart.setProp('spud','bud')
      cart.setProp('love','dove')
      expect(cart.getProp('spud')).to eq "bud"
      expect(cart.getProp('love')).to eq "dove"
    end

    it 'two properties can be added to two distinct kinds of objects' do
      cart.setProp('spud','bud')
      user.setProp('love','dove')

      expect(cart.getProp('spud')).to eq "bud"
      expect(user.getProp('love')).to eq "dove"
    end

    it 'two properties can be added under oen tag.' do
      cart.setProp('spud','bud')
      cart.setProp('love','dove')
      cart.setProp('spud','stud')

      expect(cart.getProp('spud')).to eq "stud"
      expect(cart.getProp('love')).to eq "dove"
    end

    it 'a HashWithIndifferentAccess can be set to a property' do
      hsh = ActiveSupport::HashWithIndifferentAccess.new(love: 'dove')
      cart.setProp('spud', hsh)

      expect(cart.getProp('spud')).to eq hsh
    end
  end

  describe '#clear_props!' do
    it 'removes all existing properties' do
      cart.setProp('spud', 'bud')
      cart.setProp('abc', 'def')
      expect(cart.properties.length).to be(2)

      cart.clear_props!
      cart.clear_association_cache
      expect(cart.properties.length).to be(0)
    end
  end
end
