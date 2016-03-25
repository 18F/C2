describe ScheduledReportsController do
  let(:user) { create(:user, client_slug: "test") }

  before do
    login_as(user)
  end

  describe "#create" do
    it "creates new subscription with JSON" do
      my_report = create(:report, user: user)
      post :create, name: "test scheduled report", frequency: "never", report_id: my_report.id, format: :json
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to include "application/json"
      expect(response.body).to include "test scheduled report"
    end

    it "creates new subscription with HTML" do
      my_report = create(:report, user: user)
      post :create, name: "test scheduled report", frequency: "never", report_id: my_report.id
      expect(response.status).to eq 302
    end
  end

  describe "#update" do
    it "update existing subscription JSON" do
      my_report = create(:report, user: user)
      scheduled_report = create(:scheduled_report, report: my_report, user: user, frequency: "never")
      put :update, id: scheduled_report.id, frequency: "daily", format: :json
      expect(response.status).to eq 200
      expect(response.body).to include "daily"
    end

    it "update existing subscription HTML" do
      my_report = create(:report, user: user)
      scheduled_report = create(:scheduled_report, report: my_report, user: user, frequency: "never")
      put :update, id: scheduled_report.id, frequency: "daily"
      expect(response.status).to eq 302
    end
  end
end
