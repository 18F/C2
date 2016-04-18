describe ValueHelper do
  describe "#property_display_value" do
    context "value is present" do
      it "calls `property_to_s`" do
        value = "value"
        allow(helper).to receive(:property_to_s).with(value)

        helper.property_display_value(value)

        expect(helper).to have_received(:property_to_s).with(value)
      end
    end

    context "value is false" do
      it "calfls `property_to_s`" do
        value = false
        allow(helper).to receive(:property_to_s).with(value)

        helper.property_display_value(value)

        expect(helper).to have_received(:property_to_s).with(value)
      end
    end

    context "value is nil" do
      it "returns a dash" do
        value = nil

        display_value = helper.property_display_value(value)

        expect(display_value).to eq "-"
      end
    end

    context "value is empty string" do
      it "returns a dash" do
        value = ""

        display_value = helper.property_display_value(value)

        expect(display_value).to eq "-"
      end
    end
  end

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

    it "converts `true` to 'Yes'" do
      value = helper.property_to_s(true)

      expect(value).to eq "Yes"
    end

    it "converts `false` to 'No'" do
      value = helper.property_to_s(false)

      expect(value).to eq "No"
    end
  end

  describe '#date_with_tooltip' do
    it "doesn't convert time to relative time when unspecified" do
      date = DateTime.new(2015,8,15,4,5,6).in_time_zone("Eastern Time (US & Canada)").strftime("%b %-d, %Y at %l:%M%P")
      expect(helper.date_with_tooltip(date)).to eq('<span title="Aug 15, 2015 at 12:05am">Aug 15, 2015 at 12:05am</span>')  
    end

    it "converts time to relative time when specified" do
      date = DateTime.new(2015,8,15,4,5,6).in_time_zone
      date_str = date.strftime("%b %-d, %Y at %l:%M%P")
      relative_date = time_ago_in_words(date)
      expect(helper.date_with_tooltip(date,true)).to eq('<span title="' + date_str + '">' + relative_date + ' ago</span>')
    end
  end
end
