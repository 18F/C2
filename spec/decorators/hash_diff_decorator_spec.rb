describe HashDiffDecorator do
  describe '.html_for' do
    it "renders add events" do
      output = HashDiffDecorator.html_for(['+', 'foo', 'bar'])
      expect(output).to eq("<code>foo</code> was set to <code>bar</code>.")
    end
  end
end
