describe HashDiffDecorator do
  describe '#to_html' do
    it "renders add events" do
      decorated = HashDiffDecorator.new(['+', 'foo', 'bar'])
      expect(decorated.to_html).to eq("<li><code>foo</code> was set to <code>bar</code>.</li>")
    end
  end
end
