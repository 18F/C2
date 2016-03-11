describe ScheduledReportPolicy do
  permissions :can_show? do
    it "allows the owner to show" do
      report = create(:scheduled_report)
      expect(ScheduledReportPolicy).to permit(report.user, report)
    end
  end

  permissions :can_update? do
    it "allows owner to update" do
      report = create(:scheduled_report)
      expect(ScheduledReportPolicy).to permit(report.user, report)
    end
  end
end
