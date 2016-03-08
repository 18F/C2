describe ScheduledReport do
  describe "#monthly?" do
    it "recognizes monthly frequency" do
      scheduled_report = create(:scheduled_report, frequency: :monthly)
      expect(scheduled_report.monthly?).to eq(true)
      expect(scheduled_report.daily?).to eq(false)
    end
  end

  describe "#daily?" do
    it "recognizes daily frequency" do
      scheduled_report = create(:scheduled_report, frequency: :daily)
      expect(scheduled_report.daily?).to eq(true)
      expect(scheduled_report.weekly?).to eq(false)
    end
  end

  describe "#weekly?" do
    it "recognizes weekly frequency" do
      scheduled_report = create(:scheduled_report, frequency: :weekly)
      expect(scheduled_report.weekly?).to eq(true)
      expect(scheduled_report.daily?).to eq(false)
    end
  end
end
