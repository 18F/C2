describe ScheduledReporter do
  describe "#new" do
    it "requires a Time object instantiation" do
      now = Time.current
      reporter = ScheduledReporter.new(now)

      expect(reporter.check_time).to eq(now)
    end

    it "raises exception if arg is not a Time" do
      expect {
        ScheduledReporter.new("foo")
      }.to raise_error ArgumentError
    end
  end
end
