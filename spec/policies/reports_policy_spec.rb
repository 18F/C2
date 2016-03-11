describe ReportPolicy do
  permissions :can_show? do
    it "allows the owner to see it" do
      report = create(:report)
      expect(ReportPolicy).to permit(report.user, report)
    end

    it "allows shared report to be viewed by user with same client_slug" do
      report = create(:report, shared: true)
      other_user = create(:user, client_slug: report.user.client_slug)
      expect(ReportPolicy).to permit(other_user, report)
    end
  end

  permissions :can_preview? do
    it "allows the owner to send a copy via email" do
      report = create(:report)
      expect(ReportPolicy).to permit(report.user, report)
    end

    it "allows anyone who can see it to send a copy via email" do
      report = create(:report, shared: true)
      other_user = create(:user, client_slug: report.user.client_slug)
      expect(ReportPolicy).to permit(other_user, report)
    end
  end

  permissions :can_destroy? do
    it "allows the owner to destroy" do
      report = create(:report)
      expect(ReportPolicy).to permit(report.user, report)
    end

    it "shared report only destroy-able by owner" do
      report = create(:report)
      other_user = create(:user, client_slug: report.user.client_slug)
      expect(ReportPolicy).to_not permit(other_user, report)
    end
  end
end
