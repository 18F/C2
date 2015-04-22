describe ValueHelper do
  describe '#property_to_s' do
    it "doesn't modify strings" do
      expect(helper.property_to_s('foo')).to eq('foo')
    end

    it "converts floats to currency" do
      expect(helper.property_to_s(1.00)).to eq('$1.00')
    end

    it "converts BigDemicals to currency" do
      val = BigDecimal.new('1.00')
      expect(helper.property_to_s(val)).to eq('$1.00')
    end
  end
end
