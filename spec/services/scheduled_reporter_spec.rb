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

  describe "#run", :elasticsearch do
    it "always sends dailes" do
      deliveries.clear
      owner = create(:user)
      report = create(:report, query: { text: "something" }.to_json, user: owner)
      scheduled_report = create(:scheduled_report, frequency: "daily", user: owner, report: report)

      scheduled_reporter = ScheduledReporter.new(Time.current)

      es_execute_with_retries 3 do
        scheduled_reporter.run
      end

      expect(deliveries.size).to eq(1)
    end

    it "sends weeklies on Mondays" do
      deliveries.clear
      scheduled_report = weekly_scheduled_report
      monday = Time.zone.parse("2016-03-07")
      reporter = ScheduledReporter.new(monday)

      es_execute_with_retries 3 do
        reporter.run
      end

      expect(deliveries.size).to eq(1)
    end

    it "only sends weeklies on Mondays" do
      deliveries.clear
      scheduled_report = weekly_scheduled_report
      tuesday = Time.zone.parse("2016-03-08")
      reporter = ScheduledReporter.new(tuesday)

      es_execute_with_retries 3 do
        reporter.run
      end

      expect(deliveries.size).to eq(0)
    end

    it "sends monthlies on first day of the month" do
      deliveries.clear
      scheduled_report = monthly_scheduled_report
      first_day_of_month = Time.zone.parse("2016-04-01")
      reporter = ScheduledReporter.new(first_day_of_month)

      es_execute_with_retries 3 do
        reporter.run
      end

      expect(deliveries.size).to eq(1)
    end

    it "sends monthlies only on first day of the month" do
      deliveries.clear
      scheduled_report = monthly_scheduled_report
      second_day_of_month = Time.zone.parse("2016-04-02")
      reporter = ScheduledReporter.new(second_day_of_month)

      es_execute_with_retries 3 do
        reporter.run
      end

      expect(deliveries.size).to eq(0)
    end
  end

  def weekly_scheduled_report
    owner = create(:user)
    report = create(:report, query: { text: "something" }.to_json, user: owner)
    scheduled_report = create(:scheduled_report, frequency: "weekly", user: owner, report: report)
  end

  def monthly_scheduled_report
    owner = create(:user)
    report = create(:report, query: { text: "something" }.to_json, user: owner)
    scheduled_report = create(:scheduled_report, frequency: "monthly", user: owner, report: report)
  end
end
