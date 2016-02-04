describe ReportsController do
  def user
    @_user ||= create(:user, client_slug: "test")
  end

  before do
    login_as(user)
  end

  it "#index" do
    report = create(:report, user: user)
    get :index
    expect(response.status).to eq 200
    expect(assigns(:reports)).to eq [report]
  end

  it "#show" do
    my_report = create(:report, user: user)
    get :show, id: my_report.id
    expect(response.status).to eq 200
    expect(assigns(:report)).to eq my_report
  end

  it "#create" do
    post :create, name: "test report", query: { user.client_model_slug => { amount: 123 } }.to_json, format: :json
    expect(response.status).to eq 201
    expect(response.headers["Content-Type"]).to include "application/json"
    expect(response.body).to include "test report"
  end

  it "#destroy (html)" do
    my_report = create(:report, user: user)
    post :destroy, id: my_report.id
    expect(response.status).to eq 302
  end

  it "#destroy (json)" do
    my_report = create(:report, user: user)
    post :destroy, id: my_report.id, format: :json
    expect(response.status).to eq 202
  end
end
