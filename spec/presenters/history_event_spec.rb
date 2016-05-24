describe HistoryEvent do
  describe "#safe_html_diff" do
    it "calls :to_html on the decorated C2Version" do
      version = instance_double("C2Version")
      decorated_version = instance_double("C2VersionDecorator")
      some_html = double("html string")
      event = described_class.new(version)

      allow(C2VersionDecorator).to receive(:new).and_return(decorated_version)
      allow(decorated_version).to receive(:to_html).and_return(some_html)

      expect(C2VersionDecorator).to receive(:new)
      expect(decorated_version).to receive(:to_html)
      expect(some_html).to receive(:html_safe)

      event.safe_html_diff
    end
  end
end
