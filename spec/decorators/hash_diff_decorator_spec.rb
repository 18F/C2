describe HashDiffDecorator do
  describe '#to_html' do
    it "renders add events" do
      decorated = HashDiffDecorator.new(['+', 'foo', 'bar'])
      expect(decorated.to_html).to eq("<code>foo</code> was set to <code>bar</code>.")
    end
  end
end
