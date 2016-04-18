describe HashDiffDecorator do
  describe '.html_for' do
    it "renders add events" do
      output = HashDiffDecorator.html_for(type: '+', field: 'foo', val1: 'bar')
      expect(output).to eq("<span>foo</span> was set to <strong>&quot;bar&quot;</strong>.")
    end

    it "renders modification events" do
      output = HashDiffDecorator.html_for(type: '~', field: 'foo', val1: 'bar', val2: 'baz')
      expect(output).to eq("<span>foo</span> was changed from <strong>&quot;bar&quot;</strong> to <strong>&quot;baz&quot;</strong>")
    end

    it "renders removal events" do
      output = HashDiffDecorator.html_for(type: '-', field: 'foo')
      expect(output).to eq("<span>foo</span> was removed.")
    end

    it "renders original-was-nil events" do
      output = HashDiffDecorator.html_for(type: '~', field: 'foo', val1: nil, val2: 'bar')
      expect(output).to eq("<span>foo</span> was changed from <strong>[nil]</strong> to <strong>&quot;bar&quot;</strong>")
    end

    it "renders original-was-empty-string events" do
      output = HashDiffDecorator.html_for(type: '~', field: 'foo', val1: '', val2: 'bar')
      expect(output).to eq("<span>foo</span> was changed from <strong>[empty]</strong> to <strong>&quot;bar&quot;</strong>")
    end

    it "renders numeric events" do
      output = HashDiffDecorator.html_for(type: '~', field: 'a_number', val1: 456, val2: 123)
      expect(output).to eq("<span>a_number</span> was changed from <strong>456</strong> to <strong>123</strong>")
      output = HashDiffDecorator.html_for(type: '~', field: 'a_float', val1: 123.0, val2: 456.9)
      expect(output).to eq("<span>a_float</span> was changed from <strong>123.00</strong> to <strong>456.90</strong>")
    end

    context "when the change includes an object value" do
      context "and the object can translate keys" do
        it "translates object keys" do
          output = HashDiffDecorator.html_for(type: '-', field: 'soc_code', object: work_order)
          expect(output).to eq("<span>Object Field / SOC Code</span> was removed.")
        end
      end

      context "and the object cannot translate keys" do
        it "prints the raw field name from the change" do
          output = HashDiffDecorator.html_for(type: '-', field: 'soc_code', object: 12)
          expect(output).to eq("<span>soc_code</span> was removed.")
        end
      end
    end
  end
end

def work_order
  create(:ncr_work_order).decorate
end
