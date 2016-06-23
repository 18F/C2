describe ReportsController do
  let(:user) { create(:user, client_slug: "test") }

  before do
    login_as(user)
  end

  describe "#index" do
    it "shows list of reports" do
      report = create(:report, user: user)
      get :index
      expect(response.status).to eq 200
      expect(assigns(:reports)).to eq [report]
    end
  end

  describe "#show" do
    it "shows a single report details" do
      my_report = create(:report, user: user)
      get :show, id: my_report.id
      expect(response.status).to eq 200
      expect(assigns(:report)).to eq my_report
    end
  end

  describe "#create" do
    it "creates new report" do
      post :create, name: "test report", query: { user.client_model_slug => { amount: 123 } }.to_json, format: :json
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to include "application/json"
      expect(response.body).to include "test report"
    end
  end

  describe "#destroy (html)" do
    it "HTML content type responds with redirect" do
      my_report = create(:report, user: user)
      post :destroy, id: my_report.id
      expect(response.status).to eq 302
    end
  end

  describe "#destroy (json)" do
    it "JSON content type responds with JSON payload" do
      my_report = create(:report, user: user)
      post :destroy, id: my_report.id, format: :json
      expect(response.status).to eq 202
    end
  end

  describe "#preview", :elasticsearch do
    it "sends email with report to current user", :email do
      my_report = create(:report, user: user)
      es_execute_with_retries 3 do
        post :preview, id: my_report.id
        expect(response.status).to eq 302
        expect(deliveries.size).to eq 1
      end
    end
  end
end
