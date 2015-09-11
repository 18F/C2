describe HashDiffDecorator do
  describe '.html_for' do
    it "renders add events" do
      output = HashDiffDecorator.html_for(['+', 'foo', 'bar'])
      expect(output).to eq("<code>foo</code> was set to <code>bar</code>.")
    end

    it "renders modification events" do
      output = HashDiffDecorator.html_for(['~', 'foo', 'bar', 'baz'])
      expect(output).to eq("<code>foo</code> was changed from <code>&quot;bar&quot;</code> to <code>&quot;baz&quot;</code>")
    end

    it "renders removal events" do
      output = HashDiffDecorator.html_for(['-', 'foo'])
      expect(output).to eq("<code>foo</code> was removed.")
    end
  end
end
